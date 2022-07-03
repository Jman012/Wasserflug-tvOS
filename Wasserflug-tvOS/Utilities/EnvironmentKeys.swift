import SwiftUI

struct FPAPIServiceKey: EnvironmentKey {
	static var defaultValue: FPAPIService = MockFPAPIService()
}

struct ScreenWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = UIScreen.main.bounds.width;
}

extension EnvironmentValues {
	var fpApiService: FPAPIService {
		get { self[FPAPIServiceKey.self] }
		set { self[FPAPIServiceKey.self] = newValue }
	}
    
    var screenWidth: CGFloat {
        get { self[ScreenWidthKey.self] }
        set { self[ScreenWidthKey.self] = newValue }
    }
}
