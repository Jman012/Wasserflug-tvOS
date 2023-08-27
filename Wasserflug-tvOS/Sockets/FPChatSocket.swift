import Foundation
import UIKit
import Combine
import SocketIO
import FloatplaneAPIAsync

class FPChatSocket: BaseViewModel, ObservableObject, FPSocket {
	
	enum SocketError: Error {
		case missingResponseData
		case nilSocketData
		case timedOut
		case unsuccessfulJoin
	}
	
	enum Status: Hashable {
		case notConnected
		case waitingToReconnect
		case socketConnecting
		case socketConnected
		case joiningLivestreamFrequency
		case joinedLivestreamFrequency
		case leavingLivestreamFrequency
		case disconnecting
	}
	
	let channelId: String
	let selfUsername: String
	@Published fileprivate(set) var status: Status = .notConnected
	@Published var connectionError: Error? = nil
	@Published var radioChatter: [RenderedRadioChatter] = []
	
	let loadedEmotesLock = NSLock()
	@Published var loadedEmotes: [String: LoadedEmote] = [:]
	
	private let sailsSid: String
	private let timeoutSeconds: Double = 5.0
	private let socketManager: SocketManager
	private let socket: SocketIOClient
	
	private var shouldConnect = false
	
	private var livestreamFreq: String {
		return "/live/" + channelId
	}
	
	init(sailsSid: String, channelId: String, selfUsername: String) {
		self.sailsSid = sailsSid
		socketManager = SocketManager(
			socketURL: URL(string: "wss://chat.floatplane.com")!,
			config: [
				.log(false),
				.compress,
				.forceWebsockets(true),
				.extraHeaders([
					"Origin": "https://www.floatplane.com",
				]),
				// Utilize system cookie manager for sails.sid cookie
				.cookies([]),
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
		self.selfUsername = selfUsername
		
		super.init()
		
		bindEvents(socket: socket)
	}
	
	func connect() {
		connectionError = nil
		shouldConnect = true
		continueConnecting()
	}
	
	func disconnect() {
		shouldConnect = false
		continueDisconnecting()
	}
	
	private func continueConnecting() {
		switch status {
		case .notConnected, .waitingToReconnect:
			// Begin connecting the socket
			self.logger.info("Establishing chat socket connection")
			self.socket.connect()
			self.status = .socketConnecting
		case .socketConnecting:
			// Do nothing, still waiting for socket connection to establish
			break
		case .socketConnected:
			/// Socket connection established, join livestream freq
			logger.info("Joining livestream radio frequency", metadata: [
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
				
				self.logger.info("Joined livestream radio frequency", metadata: [
					"channel": "\(self.livestreamFreq)",
					"emotes": "\(joinedResponse.body.emotes ?? [])",
				])
				
				self.asyncLoadEmotes(from: joinedResponse)
				
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
	
	private func continueDisconnecting() {
		let hardDisconnect: () -> Void = {
			self.logger.info("Disconnecting chat socket connection")
			self.status = .disconnecting
			self.socket.disconnect()
		}
		
		switch status {
		case .notConnected:
			// Do nothing, already disconnected
			break
		case .waitingToReconnect:
			// Stop attempt to disconnect
			hardDisconnect()
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
			logger.info("Leaving livestream frequency", metadata: [
				"channel": "\(livestreamFreq)",
			])
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
			
				self.logger.info("Left livestream frequency", metadata: [
					"channel": "\(self.livestreamFreq)",
				])
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
			self.logger.info("Chat socket connection established")
			self.status = .socketConnected
			self.connectionError = nil
			self.continueConnecting()
		})
		socket.on(clientEvent: .disconnect, callback: { data, ack in
			if self.shouldConnect {
				self.logger.info("Chat socket connection has been closed unexpectedly. Reconnecting after 5 seconds")
				self.status = .notConnected
				self.connectionError = nil
				DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
					self.continueConnecting()
				})
			} else {
				self.logger.info("Chat socket connection has been closed")
				self.status = .notConnected
				self.connectionError = nil
			}
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
			
			// Ignore emotes from channels we're not joined to.
			guard radioChatter.channel != self.channelId else {
				return
			}
			
			self.logger.info("Radio chatter [\(self.livestreamFreq)]: \(String(reflecting: radioChatter))")
			let rendered = RenderedRadioChatter(radioChatter: radioChatter, loadedEmotes: self.loadedEmotes, selfUsername: self.selfUsername)
			self.radioChatter.append(rendered)
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
	
	private func asyncLoadEmotes(from joinedResponse: JoinedLivestreamRadioFrequency) {
		for emote in joinedResponse.body.emotes ?? [] {
			if let url = URL(string: emote.image) {
				let request = URLRequest(url: url)
				let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
					guard let httpResp = response as? HTTPURLResponse,
						  let data,
						  let image = UIImage(data: data),
						  error == nil && httpResp.isResponseOK() else {
						return
					}
					
					// Resize the emote to 32x32
					let resizedImage = UIGraphicsImageRenderer(size: .init(width: 32, height: 32)).image { _ in
						image.draw(in: CGRect(origin: .zero, size: .init(width: 32, height: 32)))
					}
					DispatchQueue.main.async {
						self.loadedEmotesLock.withLock {
							self.loadedEmotes[emote.code] = LoadedEmote(emote: emote, image: resizedImage)
						}
					}
				})
				task.resume()
			}
		}
	}
}

class MockFPChatSocket: FPChatSocket {
	static let all: [MockFPChatSocket] = [
		.withNotConnected,
		.withWaitingtoReconnect,
		.withBlankConnecting,
		.withConnectionError,
		.withChatter,
	]
	
	static let withNotConnected = MockFPChatSocket(display: "Not connected", channelId: "", status: .notConnected, connectionError: nil, radioChatter: [])
	static let withWaitingtoReconnect = MockFPChatSocket(display: "Waiting to reconnect", channelId: "", status: .waitingToReconnect, connectionError: nil, radioChatter: [])
	static let withBlankConnecting = MockFPChatSocket(display: "Blank connecting", channelId: "", status: .joiningLivestreamFrequency, connectionError: nil, radioChatter: [])
	static let withConnectionError = MockFPChatSocket(display: "Connection error", channelId: "", status: .socketConnected, connectionError: FPChatSocket.SocketError.timedOut, radioChatter: [])
	static let withChatter = MockFPChatSocket(display: "Chatter", channelId: "", status: .joinedLivestreamFrequency, connectionError: nil, radioChatter: [
		.init(channel: "", emotes: nil, id: "0", message: "message 0", success: nil, userGUID: "", username: "user 0", userType: .normal),
		.init(channel: "", emotes: nil, id: "1", message: "message 1", success: nil, userGUID: "", username: "user 1", userType: .normal),
		.init(channel: "", emotes: nil, id: "2", message: "message 2", success: nil, userGUID: "", username: "user 2", userType: .normal),
		.init(channel: "", emotes: nil, id: "3", message: "message 3", success: nil, userGUID: "", username: "user 3", userType: .normal),
		.init(channel: "", emotes: nil, id: "4", message: "message 4", success: nil, userGUID: "", username: "user 4", userType: .normal),
		.init(channel: "", emotes: nil, id: "5", message: "message 5", success: nil, userGUID: "", username: "user 5", userType: .normal),
		.init(channel: "", emotes: nil, id: "6", message: "message 6", success: nil, userGUID: "", username: "user 6", userType: .normal),
		.init(channel: "", emotes: nil, id: "7", message: "message 7", success: nil, userGUID: "", username: "user 7", userType: .normal),
		.init(channel: "", emotes: nil, id: "8", message: "message 8", success: nil, userGUID: "", username: "user 8", userType: .normal),
		.init(channel: "", emotes: nil, id: "9", message: "message 9", success: nil, userGUID: "", username: "user 9", userType: .normal),
	])
	
	let display: String
	
	init(display: String, channelId: String, status: FPChatSocket.Status, connectionError: Error?, radioChatter: [RadioChatter]) {
		self.display = display
		super.init(sailsSid: "", channelId: channelId, selfUsername: "jamamp")
		self.status = status
		self.connectionError = connectionError
		self.radioChatter = radioChatter.map({ .init(radioChatter: $0, loadedEmotes: [:], selfUsername: "jamamp") })
	}

	override func connect() {
	}
	
	override func disconnect() {
	}
}

extension MockFPChatSocket: Hashable {
	static func == (lhs: MockFPChatSocket, rhs: MockFPChatSocket) -> Bool {
		return lhs.display == rhs.display
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(display)
	}
}
