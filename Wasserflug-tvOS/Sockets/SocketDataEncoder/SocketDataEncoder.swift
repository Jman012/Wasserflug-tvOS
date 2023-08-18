import Foundation
import Combine
import SocketIO

class SocketDataEncoder: TopLevelEncoder {
	typealias Output = SocketData?
	
	public var userInfo: [CodingUserInfoKey : Any] = [:]
	
	public init() {}
	
	func encode<T>(_ value: T) throws -> Output where T : Encodable {
		let encoder = SocketDataEncoderImpl()
		encoder.userInfo = self.userInfo
		
		try value.encode(to: encoder)
		
		return encoder.data
	}
}

class SocketDataEncoderImpl: Encoder {
	var codingPath: [CodingKey] = []
	var userInfo: [CodingUserInfoKey : Any] = [:]
	
	fileprivate var container: SocketDataEncodingContainer?
		
	var data: SocketData? {
//		return container?.data ?? Dictionary<String, String>()
		container?.data
	}
	
	fileprivate func assertCanCreateContainer() {
		precondition(container == nil)
	}
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		assertCanCreateContainer()
		
		let container = SocketDataKeyedEncodingContainer<Key>(codingPath: codingPath, userInfo: userInfo)
		self.container = container
		
		return KeyedEncodingContainer(container)
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		assertCanCreateContainer()
		
		let container = SocketDataUnkeyedEncodingContainer(codingPath: codingPath, userInfo: userInfo)
		self.container = container
		
		return container
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		assertCanCreateContainer()
		
		let container = SocketDataSingleValueEncodingContainer(codingPath: codingPath, userInfo: userInfo)
		self.container = container
		
		return container
	}
}
