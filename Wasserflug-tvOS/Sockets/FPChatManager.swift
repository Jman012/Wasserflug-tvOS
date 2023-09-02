import Foundation
import UIKit
import Logging
import SocketIO
import FloatplaneAPIAsync

protocol FPChatManagerInternal: AnyObject {
	func connect(client: FPChatManagerDelegate)
	func disconnect(client: FPChatManagerDelegate)
}

enum FPChatConnectionStatus: Hashable {
	/// Not yet connected, with no desire to connect yet
	case notConnected
	/// Waiting for connection to complete
	case connecting
	/// Fully connected and ready
	case connected
	/// Disconnected by request
	case disconnectedBySelf
	/// Disconnected via error, and will try to reconnect
	case unexpectedlyDisconnected
}

class FPChatManager: BaseViewModel {
	enum SocketError: Error {
		case missingResponseData
		case nilSocketData
		case timedOut
		case unsuccessfulJoin
		case unsuccessfulLeave
	}
	
	static let defaultFPChatSocketManager = SocketManager(
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
	
	private(set) var status: FPChatConnectionStatus
	
	private let socket: SocketIOClient
	private var clients: [String: FPChatManagerDelegate] = [:]
	
	private let loadedEmotesLock = NSLock()
	private var loadedEmotes: [String: LoadedEmote] = [:]
	
	init(socket: SocketIOClient? = nil) {
		self.socket = socket ?? Self.defaultFPChatSocketManager.defaultSocket
		
		// Initial sync of status from the socket client
		switch self.socket.status {
		case .notConnected:
			status = .notConnected
		case .connecting:
			status = .connecting
		case .connected:
			status = .connected
		case .disconnected:
			status = .unexpectedlyDisconnected
		}
		
		super.init()
		
		handleUpstreamSocketEvents()
	}
	
	func client(forChannel channel: String, selfUserName: String) -> some FPChatClient {
		if let client = clients[channel] {
			return client as! FPChatClientImpl
		}
		
		logger.info("Creating client for channel \(channel)")
		let client = FPChatClientImpl(manager: self, channel: channel, selfUsername: selfUserName)
		clients[channel] = client
		return client
	}
}

extension FPChatManager: FPSocket {
	func connect() {
		switch status {
		case .notConnected:
			logger.info("Connecting chat manager socket")
			status = .connecting
			socket.connect()
		case .connecting, .connected:
			break
		case .disconnectedBySelf, .unexpectedlyDisconnected:
			logger.info("Reconnecting chat manager socket")
			status = .connecting
			socket.connect()
		}
	}
	
	func disconnect() {
		switch status {
		case .notConnected:
			break
		case .connecting, .connected:
			logger.info("Disconnecting chat manager socket")
			status = .disconnectedBySelf
			socket.disconnect()
		case .disconnectedBySelf, .unexpectedlyDisconnected:
			break
		}
	}
}

/// Events from downstream clients
extension FPChatManager: FPChatManagerInternal {
	func connect(client: FPChatManagerDelegate) {
		switch status {
		case .notConnected, .disconnectedBySelf, .unexpectedlyDisconnected:
			// Connect the SocketIOClient. Once that's connected, the
			// handler will then connect our chat clients that are waiting
			// to join their channels.
			logger.info("Connecting chat manager socket")
			status = .connecting
			socket.connect()
		case .connecting:
			// SocketIOClient is still connecting, do nothing until it either
			// connects or times out or errors out.
			break
		case .connected:
			// SocketIOClient is all setup. Good to connect the chat client.
			connect(client: client, on: socket)
		}
	}
	
	func disconnect(client: FPChatManagerDelegate) {
		switch status {
		case .notConnected, .connecting, .disconnectedBySelf, .unexpectedlyDisconnected:
			// No need to do anything when already not/dis- connected,
			// except confirm to the client that it disconnected
			// (which it should have known already)
			client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
		case .connected:
			// Attempt to leave the channel
			disconnect(client: client, on: socket)
			// But tell the client it's been disconnected immediately
			client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
		}
	}
}

/// Handle upstream events from the socket connection
extension FPChatManager {
	private func handleUpstreamSocketEvents() {
		socket.on(clientEvent: .connect, callback: { _, _ in
			// SocketIO connection has been made
			self.logger.info("Chat manager socket connected")
			
			// Manager status is now connected, like the socket.
			self.status = .connected
			
			// Connect each of our chat clients that are awaiting connection
			for (_, client) in self.clients {
				// If a client is connecting, it was waiting for this manager's socket
				// connection to complete first. If it was unexpectedly disconnected,
				// it should also attempt to reconnect.
				if client.status == .connecting || client.status == .unexpectedlyDisconnected {
					self.connect(client: client, on: self.socket)
				}
			}
		})
		socket.on(clientEvent: .disconnect, callback: { _, _ in
			switch self.status {
			case .notConnected:
				break
			case .connecting, .connected:
				self.logger.warning("Chat manager unexpectedly disconnected")
				self.status = .unexpectedlyDisconnected
			case .disconnectedBySelf:
				self.logger.info("Chat manager disconnected")
			case .unexpectedlyDisconnected:
				break
			}
			
			// Disconnect all clients
			for (_, client) in self.clients {
				if client.status == .connecting || client.status == .connected {
					client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
				}
			}
		})
		socket.on(clientEvent: .error, callback: { data, _ in
			for (_, client) in self.clients where client.status == .connected {
				self.logger.warning("Chat manager socket received error: \(String(reflecting: data))")
				// TODO: get error
//				client.manager(self, didReceiveError: error)
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
			
			let channel = String(radioChatter.channel.trimmingPrefix("/live/"))
			guard let client = self.clients[channel] else {
				// Skip radio chatter from unknown/unconnected client
				self.logger.warning("Received radio chatter for unknown chat client on channel \(channel): \(radioChatter)")
				return
			}
			
			let rendered = RenderedRadioChatter(radioChatter: radioChatter, loadedEmotes: self.loadedEmotes, selfUsername: client.selfUsername)
			client.manager(self, didReceiveRadioChatter: rendered)
		})
	}
}

/// Private methods for handling client connection and disconnection requests
extension FPChatManager {
	private func connect(client: FPChatManagerDelegate, on socket: SocketIOClient) {
		var logger = logger
		logger[metadataKey: "channel"] = "\(client.channel)"
		logger.info("Chat manager connecting client")
		
		let joinRequest = JoinLivestreamRadioFrequency(
			data: .init(channel: "/live/" + client.channel, message: JSONNull()),
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
			client.manager(self, didReceiveError: error)
			client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
			return
		}
		
		socket.emitWithAck("get", joinRequestSocketData).timingOut(after: 5.0, callback: { data in
			guard !data.isSocketIONoAck else {
				logger.warning("Timed out joining livestream frequency")
				client.manager(self, didReceiveError: SocketError.timedOut)
				client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
				return
			}
			
			let joinedResponse: JoinedLivestreamRadioFrequency
			do {
				joinedResponse = try self.decode(JoinedLivestreamRadioFrequency.self, from: data)
			} catch {
				logger.warning("Failed to decode JoinedLivestreamRadioFrequency response: \(error). Data: \(String(reflecting: data))")
				client.manager(self, didReceiveError: error)
				client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
				return
			}
			
			guard joinedResponse.statusCode == 200 && joinedResponse.body.success else {
				logger.warning("Failed to join livestream radio frequency: \(String(reflecting: joinedResponse))")
				client.manager(self, didReceiveError: SocketError.unsuccessfulJoin)
				client.manager(self, didDisconnectFromChannel: .init(body: [:], headers: [:], statusCode: 0))
				return
			}
			
			logger.info("Joined livestream radio frequency", metadata: [
				"emotes": "\(joinedResponse.body.emotes ?? [])",
			])
			
			self.asyncLoadEmotes(from: joinedResponse)
			
			client.manager(self, didConnectToChannel: joinedResponse)
		})
	}
	
	private func disconnect(client: FPChatManagerDelegate, on socket: SocketIOClient) {
		var logger = logger
		logger[metadataKey: "channel"] = "\(client.channel)"
		
		logger.info("Chat manager leaving livestream frequency")
		let leaveRequest = LeaveLivestreamRadioFrequency(
			data: .init(channel: "/live/" + client.channel, message: "Bye!"),
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
			client.manager(self, didReceiveError: error)
			return
		}
		
		socket.emitWithAck("post", leaveRequestSocketData).timingOut(after: 5, callback: { data in
			guard !data.isSocketIONoAck else {
				// Kill the connection despite failing to leave livestream freq
				logger.warning("Timed out leaving livestream freq. Disconnecting socket anyway.")
				client.manager(self, didReceiveError: SocketError.timedOut)
				return
			}
			
			let leftResponse: LeftLivestreamRadioFrequency
			do {
				leftResponse = try self.decode(LeftLivestreamRadioFrequency.self, from: data)
			} catch {
				logger.warning("Failed to decode LeftLivestreamRadioFrequency response: \(error). Data: \(String(reflecting: data))")
				client.manager(self, didReceiveError: error)
				return
			}
			
			guard leftResponse.statusCode == 200 else {
				logger.warning("Failed to leave livestream radio frequency: \(String(reflecting: leftResponse))")
				client.manager(self, didReceiveError: SocketError.unsuccessfulLeave)
				return
			}
		
			logger.info("Chat manager left livestream frequency")
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
			guard let url = URL(string: emote.image) else {
				logger.warning("Unknown url for emote \(emote). Skipping preloading.")
				return
			}
			
			let request = URLRequest(url: url)
			let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
				guard let httpResp = response as? HTTPURLResponse,
					  let data,
					  let image = UIImage(data: data),
					  error == nil && httpResp.isResponseOK() else {
					self.logger.warning("Chat manager failed to preload livestream emote. Response: \(String(describing: response)), error: \(String(describing: error))")
					return
				}
					
				// Resize the emote to 32x32
				let resizedImage = UIGraphicsImageRenderer(size: .init(width: 32, height: 32)).image { _ in
					image.draw(in: CGRect(origin: .zero, size: .init(width: 32, height: 32)))
				}
				
				self.logger.info("Chat manager preloaded livestream emote \(emote)")
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
