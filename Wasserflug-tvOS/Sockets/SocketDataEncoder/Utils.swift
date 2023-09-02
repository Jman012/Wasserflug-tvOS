import Foundation
import SocketIO

extension Int8 : SocketData { }
extension Int16 : SocketData { }
extension Int32 : SocketData { }
extension Int64 : SocketData { }
extension UInt : SocketData { }
extension UInt8 : SocketData { }
extension UInt16 : SocketData { }
extension UInt32 : SocketData { }
extension UInt64 : SocketData { }
extension Float : SocketData { }

struct AnyCodingKey: CodingKey, Equatable {
	var stringValue: String
	var intValue: Int?
	
	init?(stringValue: String) {
		self.stringValue = stringValue
		self.intValue = nil
	}
	
	init?(intValue: Int) {
		self.stringValue = "\(intValue)"
		self.intValue = intValue
	}
	
	init<Key>(_ base: Key) where Key : CodingKey {
		if let intValue = base.intValue {
			self.init(intValue: intValue)!
		} else {
			self.init(stringValue: base.stringValue)!
		}
	}
}

extension AnyCodingKey: Hashable {
	func hash(into hasher: inout Hasher) {
		if let intValue {
			hasher.combine(intValue)
		} else {
			hasher.combine(stringValue)
		}
	}
}

protocol SocketDataEncodingContainer {
	var data: SocketData? { get }
}
