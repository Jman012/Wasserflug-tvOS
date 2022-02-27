import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

#if compiler(>=5.5) && canImport(_Concurrency)
extension Set: AsyncResponseEncodable where Element: Content {
	@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
	public func encodeResponse(for request: Request) async throws -> Response {
		let response = Response()
		try response.content.encode(Array(self))
		return response
	}

}

extension Set: AsyncRequestDecodable where Element: Content {
	@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
	public static func decodeRequest(_ request: Request) async throws -> Self {
		let content = try request.content.decode([Element].self)
		return Set(content)
	}
}
#endif
