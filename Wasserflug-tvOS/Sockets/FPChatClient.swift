import Foundation
import Combine
import FloatplaneAPIAsync

protocol FPChatClient: ObservableObject, FPSocket {
	
	var channel: String { get }
	var status: FPChatConnectionStatus { get }
	var radioChatter: [RenderedRadioChatter] { get }
	
	func connect()
	func disconnect()
}

protocol FPChatManagerDelegate {
	var channel: String { get }
	var selfUsername: String { get }
	var status: FPChatConnectionStatus { get }
	
	func manager(_ manager: FPChatManagerInternal, didConnectToChannel joinedResponse: JoinedLivestreamRadioFrequency)
	func manager(_ manager: FPChatManagerInternal, didDisconnectFromChannel leftResponse: LeftLivestreamRadioFrequency)
	func manager(_ manager: FPChatManagerInternal, didReceiveError error: Error)
	func manager(_ manager: FPChatManagerInternal, didReceiveRadioChatter radioChatter: RenderedRadioChatter)
}

class FPChatClientImpl: BaseViewModel, ObservableObject {
	let channel: String
	let selfUsername: String
	@Published private(set) var status: FPChatConnectionStatus = .notConnected
	@Published private(set) var radioChatter: [RenderedRadioChatter] = []
	
	private weak var manager: FPChatManagerInternal?
	
	init(manager: FPChatManager, channel: String, selfUsername: String) {
		self.manager = manager
		self.channel = channel
		self.selfUsername = selfUsername
		
		super.init()
		
		var channelLogger = self.logger
		channelLogger[metadataKey: "channel"] = "\(channel)"
		self.logger = channelLogger
	}
}

extension FPChatClientImpl: FPChatClient {
	func connect() {
		guard let manager, status != .connected else {
			return
		}
		logger.info("Connecting chat client")
		status = .connecting
		manager.connect(client: self)
	}
	
	func disconnect() {
		guard let manager else {
			return
		}
		logger.info("Disconnecting chat client")
		status = .disconnectedBySelf
		manager.disconnect(client: self)
	}
}

extension FPChatClientImpl: FPChatManagerDelegate {
	func manager(_ manager: FPChatManagerInternal, didConnectToChannel joinedResponse: JoinedLivestreamRadioFrequency) {
		logger.info("Chat client connected")
		status = .connected
	}

	func manager(_ manager: FPChatManagerInternal, didDisconnectFromChannel leftResponse: LeftLivestreamRadioFrequency) {
		switch status {
		case .notConnected:
			logger.info("Chat client successfully disconnected")
		case .connecting, .connected:
			logger.info("Chat client unexpectedly disconnected")
			status = .unexpectedlyDisconnected
		case .disconnectedBySelf, .unexpectedlyDisconnected:
			logger.info("Chat client successfully disconnected")
		}
	}

	func manager(_ manager: FPChatManagerInternal, didReceiveError error: Error) {
		// TODO: handle error
		logger.error("Chat client error: \(error)")
	}

	func manager(_ manager: FPChatManagerInternal, didReceiveRadioChatter radioChatter: RenderedRadioChatter) {
		self.logger.debug("Radio chatter [\(self.channel)]: \(String(reflecting: radioChatter))")
		self.radioChatter.append(radioChatter)
		if self.radioChatter.count > 50 {
			self.radioChatter = Array(self.radioChatter.dropFirst(self.radioChatter.count - 50))
		}
	}
}

class MockFPChatClient: FPChatClient {
	static let all: [MockFPChatClient] = [
		.withNotConnected,
		.withWaitingtoReconnect,
		.withBlankConnecting,
		.withDisconnectedBySelf,
		.withChatter,
	]
	
	static let withNotConnected = MockFPChatClient(display: "Not connected", channelId: "", status: .notConnected, radioChatter: [])
	static let withWaitingtoReconnect = MockFPChatClient(display: "Waiting to reconnect", channelId: "", status: .unexpectedlyDisconnected, radioChatter: [])
	static let withBlankConnecting = MockFPChatClient(display: "Blank connecting", channelId: "", status: .connecting, radioChatter: [])
	static let withDisconnectedBySelf = MockFPChatClient(display: "Disconnected by self", channelId: "", status: .disconnectedBySelf, radioChatter: [])
	static let withChatter = MockFPChatClient(display: "Chatter", channelId: "", status: .connected, radioChatter: [
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
	
	var channel: String
	var status: FPChatConnectionStatus
	var radioChatter: [RenderedRadioChatter]
	let display: String
	
	init(display: String, channelId: String, status: FPChatConnectionStatus, radioChatter: [RadioChatter]) {
		self.channel = channelId
		self.status = status
		self.radioChatter = radioChatter.map({ .init(radioChatter: $0, loadedEmotes: [:], selfUsername: "jamamp") })
		self.display = display
	}
	
	func connect() {
	}
	
	func disconnect() {
	}
}

extension MockFPChatClient: Hashable {
	static func == (lhs: MockFPChatClient, rhs: MockFPChatClient) -> Bool {
		return lhs.display == rhs.display
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(display)
	}
}
