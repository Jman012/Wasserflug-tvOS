import Foundation
import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
	@State var didTrigger = false
	let perform: () -> Void

	func body(content: Content) -> some View {
		content
			.onAppear {
				if !didTrigger {
					didTrigger = true
					perform()
				}
			}
	}
}

extension View {
	func onFirstAppear(perform: @escaping () -> Void) -> some View {
		modifier(OnFirstAppearModifier(perform: perform))
	}
}
