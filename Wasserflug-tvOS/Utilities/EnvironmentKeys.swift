import SwiftUI

struct FPAPIServiceKey: EnvironmentKey {
	static var defaultValue: FPAPIService = MockFPAPIService()
}

extension EnvironmentValues {
	var fpApiService: FPAPIService {
		get { self[FPAPIServiceKey.self] }
		set { self[FPAPIServiceKey.self] = newValue }
	}
}
