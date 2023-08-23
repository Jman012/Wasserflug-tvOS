import Foundation
import SwiftUI

enum FPColors {
	static let blue = Color("FPBlue")
	static let sidebarBlue = Color("FPSidebarBlue")
	static let playButtonBlue = Color("FPPlayButtonBlue")
	static let watchProgressIndicatorBegin = Color("WatchProgressIndicatorBegin")
	static let watchProgressIndicatorEnd = Color("WatchProgressIndicatorEnd")
	
	struct UsernameColors {
		static let usernameColor0 = Color("UsernameColor0")
		static let usernameColor1 = Color("UsernameColor1")
		static let usernameColor2 = Color("UsernameColor2")
		static let usernameColor3 = Color("UsernameColor3")
		static let usernameColor4 = Color("UsernameColor4")
		static let usernameColor5 = Color("UsernameColor5")
		static let usernameColor6 = Color("UsernameColor6")
		static let usernameColor7 = Color("UsernameColor7")
		static let usernameColor8 = Color("UsernameColor8")
		static let usernameColor9 = Color("UsernameColor9")
		
		static let all: [Color] = [
			usernameColor0,
			usernameColor1,
			usernameColor2,
			usernameColor3,
			usernameColor4,
			usernameColor5,
			usernameColor6,
			usernameColor7,
			usernameColor8,
			usernameColor9,
		]
	}
	
	struct LiveChat {
		static let buttonBg = Color("LCButtonBackground")
		static let buttonBgFocused = Color("LCButtonBackgroundFocused")
		static let headerBg = Color("LCHeaderBackground")
	}
}
