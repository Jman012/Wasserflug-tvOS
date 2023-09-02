import Foundation
import FloatplaneAPIAsync
import SocketIO

protocol FPSocket {
	func connect()
	func disconnect()
}

class MockFPFrontendSocket: FPFrontendSocket {
	override func connect() {
	}
	
	override func disconnect() {
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
