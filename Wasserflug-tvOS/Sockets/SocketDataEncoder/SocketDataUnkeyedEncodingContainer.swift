import Foundation
import SocketIO

class SocketDataUnkeyedEncodingContainer: UnkeyedEncodingContainer {
	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any]
	
	var count: Int {
		return storage.count
	}
	
	var storage: [SocketData?] = []
	
	var nestedCodingPath: [CodingKey] {
		return codingPath + [AnyCodingKey(intValue: count)!]
	}
	
	init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
		self.codingPath = codingPath
		self.userInfo = userInfo
	}
	
	private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
		let container = SocketDataSingleValueEncodingContainer(codingPath: nestedCodingPath, userInfo: userInfo)
		storage.append(container.storage)
		
		return container
	}
	
	func encodeNil() throws {
		var container = nestedSingleValueContainer()
		try container.encodeNil()
	}
	
	func encode<T>(_ value: T) throws where T : Encodable {
		var container = nestedSingleValueContainer()
		try container.encode(value)
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		let container = SocketDataKeyedEncodingContainer<NestedKey>(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
		storage.append(container.storage)
		
		return KeyedEncodingContainer(container)
	}
	
	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		let container = SocketDataUnkeyedEncodingContainer(codingPath: nestedCodingPath, userInfo: userInfo)
		storage.append(container.storage)
		
		return container
	}
	
	func superEncoder() -> Encoder {
		fatalError("Unimplemented")
	}
}

extension SocketDataUnkeyedEncodingContainer: SocketDataEncodingContainer {
	var data: SocketData? {
		return storage
	}
}
