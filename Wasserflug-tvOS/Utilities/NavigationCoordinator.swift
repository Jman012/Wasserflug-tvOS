import Foundation
import SwiftUI

enum AuthStep {
	case login
	case secondFactor
}

class NavigationCoordinator: ObservableObject {
	@Published var path = NavigationPath()

	func popToRoot() {
		path.removeLast(path.count)
	}
	
	func push(authStep: AuthStep) {
		path.append(authStep)
	}
}
