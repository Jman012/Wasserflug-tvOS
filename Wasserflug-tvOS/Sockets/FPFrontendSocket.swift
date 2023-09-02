import Foundation
import Combine
import SwiftUI
import SocketIO
import FloatplaneAPIAsync

class FPFrontendSocket: BaseViewModel, ObservableObject, FPSocket {
	
	enum SocketError: Error {
		case missingResponseData
		case nilSocketData
		case timedOut
		case unsuccessfulJoin
	}
	
	enum Status: Hashable {
		case notConnected
		case socketConnecting
		case socketConnected
		case sailsConnecting
		case sailsConnected
		case sailsDisconnecting
		case disconnecting
	}
	
	@Published private(set) var status: Status = .notConnected
	@Published var connectionError: Error? = nil
	
	private let timeoutSeconds: Double = 5.0
	private let socketManager: SocketManager
	private let socket: SocketIOClient
	
	init(sailsSid: String) {
		socketManager = SocketManager(
			socketURL: URL(string: "wss://www.floatplane.com")!,
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
		
		super.init()
		
		bindEvents(socket: socket)
	}
	
	func connect() {
		connectionError = nil
		continueConnecting()
	}
	
	func disconnect() {
		continueDisconnecting()
	}
	
	private func continueConnecting() {
		switch status {
		case .notConnected:
			// Begin connecting the socket
			logger.info("Establishing frontend socket connection")
			socket.connect()
			status = .socketConnecting
		case .socketConnecting:
			// Do nothing, still waiting for socket connection to establish
			logger.info("Still waiting on frontend socket connection")
		case .socketConnected:
			/// Socket connection established, join livestream freq
			logger.info("Frontend socket connection established, connecting to Sails")
			let sailsConnectRequest = SailsConnect(
				data: .init(),
				headers: [:],
				method: .post,
				url: .apiV3SocketConnect)
			
			let sailsConnectRequestSocketData: SocketData
			do {
				guard let data = try SocketDataEncoder().encode(sailsConnectRequest) else {
					throw SocketError.nilSocketData
				}
				sailsConnectRequestSocketData = data
			} catch {
				logger.error("Error encoding connect request: \(error)")
				connectionError = error
				return
			}
				
			socket.emitWithAck("post", sailsConnectRequestSocketData).timingOut(after: self.timeoutSeconds, callback: { data in
				guard !data.isSocketIONoAck else {
					self.logger.warning("Timed out connecting to sails")
					self.status = .socketConnected
					self.connectionError = SocketError.timedOut
					return
				}
				
				let sailsConnectedResponse: SailsConnected
				do {
					sailsConnectedResponse = try self.decode(SailsConnected.self, from: data)
				} catch {
					self.logger.warning("Failed to decode SailsConnected response: \(error). Data: \(String(reflecting: data))")
					self.status = .socketConnected
					self.connectionError = error
					return
				}
				
				guard sailsConnectedResponse.statusCode == 200 else {
					self.logger.warning("Failed to connect to Sails: \(String(reflecting: sailsConnectedResponse))")
					self.status = .socketConnected
					self.connectionError = SocketError.unsuccessfulJoin
					return
				}
				
				self.logger.info("Connected to Sails")
				self.status = .sailsConnected
			})
			
			status = .sailsConnecting
		case .sailsConnecting:
			// Do nothing, waiting on connection
			break
		case .sailsConnected:
			// Do nothing, already fully connected
			break
		case .sailsDisconnecting:
			// Do nothing, need to wait on leave request first
			break
		case .disconnecting:
			// Do nothing, need to wait on disconnection first
			break
		}
	}
	
	private func continueDisconnecting() {
		let hardDisconnect: () -> Void = {
			self.logger.info("Disconnecting frontend socket connection")
			self.status = .disconnecting
			self.socket.disconnect()
		}
		
		switch status {
		case .notConnected:
			// Do nothing, already disconnected
			break
		case .socketConnecting:
			// Attempt to interrupt connection request
			hardDisconnect()
		case .socketConnected:
			// Socket connected but not in Sails. Disconnect.
			hardDisconnect()
		case .sailsConnecting:
			// Not in Sails yet. Disconnect.
			hardDisconnect()
		case .sailsConnected:
			/// Be nice and try to officially leave the freq before severing the socket.
			logger.info("Disconnecting from Sails")
			let disconnectRequest = SailsDisconnect(
				data: .init(),
				headers: [:],
				method: .post,
				url: .apiV3SocketDisconnect)
			
			let disconnectRequestSocketData: SocketData
			do {
				guard let data = try SocketDataEncoder().encode(disconnectRequest) else {
					throw SocketError.nilSocketData
				}
				disconnectRequestSocketData = data
			} catch {
				// Kill the connection despite being connected to Sails
				logger.warning("Failed to encode Sails disconnect request. Disconnecting socket despite being connected to Sails. Error: \(error)")
				hardDisconnect()
				return
			}
			
			socket.emitWithAck("post", disconnectRequestSocketData).timingOut(after: self.timeoutSeconds, callback: { data in
				guard !data.isSocketIONoAck else {
					// Kill the connection despite failing to disconnect from Sails
					self.logger.warning("Timed out disconnecting from Sails. Disconnecting socket anyway.")
					hardDisconnect()
					return
				}
				
				let sailsDisconnected: SailsDisconnected
				do {
					sailsDisconnected = try self.decode(SailsDisconnected.self, from: data)
				} catch {
					self.logger.warning("Failed to decode SailsDisconnected response: \(error). Data: \(String(reflecting: data))")
					hardDisconnect()
					return
				}
				
				guard sailsDisconnected.statusCode == 200 else {
					self.logger.warning("Failed to disconnect from Sails: \(String(reflecting: sailsDisconnected))")
					hardDisconnect()
					return
				}
			
				self.logger.info("Disconnected from Sails")
				hardDisconnect()
			})
		case .sailsDisconnecting:
			// Do nothing, waiting on leave response
			break
		case .disconnecting:
			// Try again just in case
			socket.disconnect()
		}
	}
	
	private func bindEvents(socket: SocketIOClient) {
		socket.on(clientEvent: .connect, callback: { data, ack in
			self.logger.info("Frontend socket connection has been established")
			self.status = .socketConnected
			self.connectionError = nil
			self.continueConnecting()
		})
		socket.on(clientEvent: .disconnect, callback: { data, ack in
			self.logger.info("Frontend socket connection has been closed")
			self.status = .notConnected
			self.connectionError = nil
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
