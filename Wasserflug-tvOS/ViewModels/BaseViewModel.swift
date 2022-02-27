import Foundation
import Logging
import Vapor

class BaseViewModel {
	lazy var logger: Logger = {
		var logger = Wasserflug_tvOSApp.logger
		logger[metadataKey: "class"] = "\(Self.Type.self)"
		return logger
	}()
}

extension ClientResponse {
	fileprivate static let decoder = PlaintextDecoder()
	var plaintextDebugContent: String {
		(try? self.content.decode(String.self, using: ClientResponse.decoder)) ?? "<error decoding>"
	}
}
