// TODO: either combine event subscription or async responses?

import Foundation
import Combine
import SocketIO
import FloatplaneAPIAsync

class FPChatSocket: BaseViewModel, ObservableObject {
	
	enum SocketError: Error {
		case missingResponseData
		case nilSocketData
		case timedOut
		case unsuccessfulJoin
	}
	
	enum Status: Hashable {
		case notConnected
		case getCookie
		case socketConnecting
		case socketConnected
		case joiningLivestreamFrequency
		case joinedLivestreamFrequency
		case leavingLivestreamFrequency
		case disconnecting
	}
	
	let channelId: String
	@Published private(set) var status: Status = .notConnected
	@Published var connectionError: Error? = nil
	@Published var radioChatter: [RadioChatter] = []
	
	private let sailsSid: String
	private let timeoutSeconds: Double = 5.0
	private let socketManager: SocketManager
	private let socket: SocketIOClient
	
	private var livestreamFreq: String {
		return "/live/" + channelId
	}
	
	init(sailsSid: String, channelId: String) {
		self.sailsSid = sailsSid
		socketManager = SocketManager(
			socketURL: URL(string: "wss://chat.floatplane.com")!,
			config: [
				.log(true),
				.compress,
				.forceWebsockets(true),
				.extraHeaders([
					"Host": "chat.floatplane.com",
					"Origin": "https://www.floatplane.com",
				]),
				.cookies([
					HTTPCookie(properties: [
						.domain: ".floatplane.com",
						.path: "/",
						.name: "sails.sid",
						.value: sailsSid,
						.secure: "Secure",
						.expires: NSDate(timeIntervalSinceNow: 1_000_000_000),
					])!,
				]),
				.reconnects(false),
				.secure(true),
				.path("/socket.io/"),
				.connectParams([
					"__sails_io_sdk_version": "0.13.8",
					"__sails_io_sdk_platform": "tvos",
					"__sails_io_sdk_language": "swift",
				]),
				.version(.two),
			])
		
		socket = socketManager.defaultSocket
		self.channelId = channelId
		
		super.init()
		
		bindEvents(socket: socket)
	}
	
	func connect() {
		connectionError = nil
		continueConnecting()
	}
	
	private func continueConnecting() {
		switch status {
		case .notConnected:
//			URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://chat.floatplane.com/__getcookie")!), completionHandler: { _, _, _ in
			// Begin connecting the socket
			self.logger.info("Establishing chat socket connection")
			self.socket.connect()
			self.status = .socketConnecting
//			}).resume()
//			status = .getCookie
		case .getCookie:
			// Still doing __getCookie, do nothing
			break
		case .socketConnecting:
			// Do nothing, still waiting for socket connection to establish
			logger.info("Still waiting on chat socket connection")
		case .socketConnected:
			/// Socket connection established, join livestream freq
			logger.info("Chat socket connection established, joining livestream radio frequency", metadata: [
				"channel": "\(livestreamFreq)",
			])
			let joinRequest = JoinLivestreamRadioFrequency(
				data: .init(channel: livestreamFreq, message: JSONNull()),
				headers: [:],
				method: .methodGet,
				url: .radioMessageJoinLivestreamRadioFrequency)
			
			let joinRequestSocketData: SocketData
			do {
				guard let data = try SocketDataEncoder().encode(joinRequest) else {
					throw SocketError.nilSocketData
				}
				joinRequestSocketData = data
			} catch {
				logger.error("Error encoding join request: \(error)")
				connectionError = error
				return
			}
				
			socket.emitWithAck("get", joinRequestSocketData).timingOut(after: self.timeoutSeconds, callback: { data in
				guard !data.isSocketIONoAck else {
					self.logger.warning("Timed out joining livestream frequency")
					self.status = .socketConnected
					self.connectionError = SocketError.timedOut
					return
				}
				
				let joinedResponse: JoinedLivestreamRadioFrequency
				do {
					joinedResponse = try self.decode(JoinedLivestreamRadioFrequency.self, from: data)
				} catch {
					self.logger.warning("Failed to decode JoinedLivestreamRadioFrequency response: \(error). Data: \(String(reflecting: data))")
					self.status = .socketConnected
					self.connectionError = error
					return
				}
				
				guard joinedResponse.statusCode == 200 && joinedResponse.body.success else {
					self.logger.warning("Failed to join livestream radio frequency: \(String(reflecting: joinedResponse))")
					self.status = .socketConnected
					self.connectionError = SocketError.unsuccessfulJoin
					return
				}
				
				self.status = .joinedLivestreamFrequency
			})
			
			status = .joiningLivestreamFrequency
		case .joiningLivestreamFrequency:
			// Do nothing, waiting on connection
			break
		case .joinedLivestreamFrequency:
			// Do nothing, already fully connected
			break
		case .leavingLivestreamFrequency:
			// Do nothing, need to wait on leave request first
			break
		case .disconnecting:
			// Do nothing, need to wait on disconnection first
			break
		}
	}
	
//	func post(message: String) {
//		guard status == .joinedLivestreamFrequency else {
//			// TODO: handle error?
//			return
//		}
//
//		let radioChatterRequest = SendLivestreamRadioChatter(
//			data: .init(channel: livestreamFreq, message: message),
//			headers: [:],
//			method: .post,
//			url: .radioMessageSendLivestreamRadioChatter)
//
//		guard let radioChatterRequestSocketData = try? SocketDataEncoder().encode(radioChatterRequest) else {
//			// TODO: handle error
//			return
//		}
//
//		self.socket.emitWithAck("post", radioChatterRequestSocketData).timingOut(after: timeoutSeconds, callback: { data in
//			guard !data.isSocketIONoAck else {
//				// TODO: handle timeout
//				return
//			}
//
//			// TODO: handle response
//		})
//	}
	
	func disconnect() {
		continueDisconnecting()
	}
	
	private func continueDisconnecting() {
		let hardDisconnect: () -> Void = {
			self.logger.info("Disconnecting socket connection")
			self.socket.disconnect()
			self.status = .disconnecting
		}
		
		switch status {
		case .notConnected:
			// Do nothing, already disconnected
			break
		case .getCookie:
			// Let the __getCookie request finish
			break
		case .socketConnecting:
			// Attempt to interrupt connection request
			hardDisconnect()
		case .socketConnected:
			// Socket connected but not in livestream freq. Disconnect.
			hardDisconnect()
		case .joiningLivestreamFrequency:
			// Not in livestream freq yet. Disconnect.
			hardDisconnect()
		case .joinedLivestreamFrequency:
			/// Be nice and try to officially leave the freq before severing the socket.
			logger.info("Leaving livestream frequency")
			let leaveRequest = LeaveLivestreamRadioFrequency(
				data: .init(channel: self.livestreamFreq, message: "Bye!"),
				headers: [:],
				method: .post,
				url: .radioMessageLeaveLivestreamRadioFrequency)
			
			let leaveRequestSocketData: SocketData
			do {
				guard let data = try SocketDataEncoder().encode(leaveRequest) else {
					throw SocketError.nilSocketData
				}
				leaveRequestSocketData = data
			} catch {
				// Kill the connection despite being in livestream freq
				logger.warning("Failed to encode leave request. Disconnecting socket despite being in livestream freq. Error: \(error)")
				hardDisconnect()
				return
			}
			
			socket.emitWithAck("post", leaveRequestSocketData).timingOut(after: self.timeoutSeconds, callback: { data in
				guard !data.isSocketIONoAck else {
					// Kill the connection despite failing to leave livestream freq
					self.logger.warning("Timed out leaving livestream freq. Disconnecting socket anyway.")
					hardDisconnect()
					return
				}
				
				let leftResponse: LeftLivestreamRadioFrequency
				do {
					leftResponse = try self.decode(LeftLivestreamRadioFrequency.self, from: data)
				} catch {
					self.logger.warning("Failed to decode LeftLivestreamRadioFrequency response: \(error). Data: \(String(reflecting: data))")
					hardDisconnect()
					return
				}
				
				guard leftResponse.statusCode == 200 else {
					self.logger.warning("Failed to leave livestream radio frequency: \(String(reflecting: leftResponse))")
					hardDisconnect()
					return
				}
			
				self.logger.info("Left livestream frequency")
				hardDisconnect()
			})
		case .leavingLivestreamFrequency:
			// Do nothing, waiting on leave response
			break
		case .disconnecting:
			// Try again just in case
			socket.disconnect()
		}
	}
	
	private func bindEvents(socket: SocketIOClient) {
		socket.on(clientEvent: .connect, callback: { data, ack in
			self.status = .socketConnected
			self.connectionError = nil
			self.continueConnecting()
		})
		socket.on(clientEvent: .disconnect, callback: { data, ack in
			self.logger.info("Chat socket connection has been closed")
			self.status = .notConnected
			self.connectionError = nil
		})
		socket.on("radioChatter", callback: { args, ack in
			let radioChatter: RadioChatter
			do {
				radioChatter = try self.decode(RadioChatter.self, from: args)
			} catch {
				self.logger.warning("Failed to decode radio chatter: \(error). Data: \(String(reflecting: args))")
				// Do nothing else
				return
			}
			
			self.logger.debug("Radio chatter [\(self.livestreamFreq)]: \(String(reflecting: radioChatter))")
			self.radioChatter.append(radioChatter)
			if self.radioChatter.count > 50 {
				self.radioChatter = Array(self.radioChatter.dropFirst(self.radioChatter.count - 50))
			}
		})
	}
	
	private func decode<T>(_ type: T.Type, from data: [Any]) throws -> T where T : Decodable {
		guard let responseData = data.first else {
			throw SocketError.missingResponseData
		}
		
		let responseBytes = try JSONSerialization.data(withJSONObject: responseData)
		let response = try JSONDecoder().decode(type, from: responseBytes)
		return response
	}
}

class MockFPSocket: FPChatSocket {
	override func connect() {
		// Do nothing
	}
	
	override func disconnect() {
		// Do nothing
	}
}

extension Array where Element : Any {
	var isSocketIONoAck: Bool {
		if let first = self.first as? String, first == SocketAckStatus.noAck {
			return true
		} else {
			return false
		}
	}
}
