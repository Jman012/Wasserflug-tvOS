import Foundation
import SocketIO

class SocketDataKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any]
	
	var storage: [String: SocketData] = [:]
	
	init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
		self.codingPath = codingPath
		self.userInfo = userInfo
	}
	
	func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
		return codingPath + [key]
	}
	
	func encodeNil(forKey key: Key) throws {
		let container = SocketDataSingleValueEncodingContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
		try container.encodeNil()
		storage[key.stringValue] = container.data
	}
	
	func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
		let container = SocketDataSingleValueEncodingContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
		try container.encode(value)
		storage[key.stringValue] = container.data
	}
	
	func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		let container = SocketDataUnkeyedEncodingContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
		storage[key.stringValue] = container.storage

		return container
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		let container = SocketDataKeyedEncodingContainer<NestedKey>(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
		storage[key.stringValue] = container.storage

		return KeyedEncodingContainer(container)
	}
	
	func superEncoder() -> Encoder {
		fatalError("Unimplemented") // FIXME:
	}
	
	func superEncoder(forKey key: Key) -> Encoder {
		fatalError("Unimplemented") // FIXME:
	}
}

extension SocketDataKeyedEncodingContainer: SocketDataEncodingContainer {
	var data: SocketData? {
		return storage
	}
}
