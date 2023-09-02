import Foundation
import SocketIO

class SocketDataSingleValueEncodingContainer: SingleValueEncodingContainer {
	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any]
	
	var storage: SocketData? = nil
	
	init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
		self.codingPath = codingPath
		self.userInfo = userInfo
	}
	
	fileprivate var canEncodeNewValue = true
	fileprivate func checkCanEncode(value: Any?) throws {
		guard canEncodeNewValue else {
			let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Attempt to encode value through single value container when previously value already encoded.")
			throw EncodingError.invalidValue(value as Any, context)
		}
	}
	
	func encodeNil() throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = NSNull()
	}
	
	func encode(_ value: Bool) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: String) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Double) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Float) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Int) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Int8) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Int16) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Int32) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Int64) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: UInt) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: UInt8) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: UInt16) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: UInt32) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: UInt64) throws {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		storage = value
	}
	
	func encode(_ value: Date) throws {
		try checkCanEncode(value: value)
		defer { canEncodeNewValue = false }
		
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions.insert(.withFractionalSeconds)
		storage = formatter.string(from: value)
	}
	
	func encode<T>(_ value: T) throws where T : Encodable {
		try checkCanEncode(value: nil)
		defer { canEncodeNewValue = false }
		
		switch value {
		case let date as Date:
			try self.encode(date)
		default:
			let encoder = SocketDataEncoderImpl()
			try value.encode(to: encoder)
			storage = encoder.data
		}
	}
}

extension SocketDataSingleValueEncodingContainer: SocketDataEncodingContainer {
	var data: SocketData? {
		return storage
	}
}
