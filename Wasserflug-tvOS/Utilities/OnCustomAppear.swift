import SwiftUI

enum CustomAppear: Hashable {
	case appear
	case disappear
}

private struct CustomAppearKey: EnvironmentKey {
	static let defaultValue: CustomAppear = .disappear
}

extension EnvironmentValues {
	var customAppear: CustomAppear {
		get { self[CustomAppearKey.self] }
		set { self[CustomAppearKey.self] = newValue }
	}
}

struct OnCustomAppearModifier: ViewModifier {
	@Environment(\.customAppear) var customAppear
	
	let perform: () -> Void
	@State var didPerform = false

	func body(content: Content) -> some View {
		content
			.onAppear(perform: {
				if !didPerform && customAppear == .appear {
					perform()
					didPerform = true
				}
			})
			.onChange(of: customAppear, perform: {
				if $0 == .appear {
					perform()
				}
			})
	}
}

struct OnCustomDisappearModifier: ViewModifier {
	@Environment(\.customAppear) var customAppear
	
	let perform: () -> Void
	@State var didPerform = false

	func body(content: Content) -> some View {
		content
			.onDisappear(perform: {
				if !didPerform && customAppear == .disappear {
					perform()
					didPerform = true
				}
			})
			.onChange(of: customAppear, perform: {
				if $0 == .disappear {
					perform()
				}
			})
	}
}

extension View {
	func customAppear(_ customAppear: CustomAppear) -> some View {
		environment(\.customAppear, customAppear)
	}
	
	func onCustomAppear(perform: @escaping () -> Void) -> some View {
		modifier(OnCustomAppearModifier(perform: perform))
	}
	
	func onCustomDisappear(perform: @escaping () -> Void) -> some View {
		modifier(OnCustomDisappearModifier(perform: perform))
	}
}

/// Temporary while both sidebar and tabview are supported
struct CombinedOnCustomAppearModifier: ViewModifier {
	@Environment(\.customAppear) var customAppear
	@AppStorage(SettingsView.showNewSidebarKey) var showNewSidebar: Bool = true
	
	let perform: () -> Void

	func body(content: Content) -> some View {
		content
			.onAppear {
				if !showNewSidebar {
					perform()
				}
			}
			.onCustomAppear {
				if showNewSidebar {
					perform()
				}
			}
	}
}

struct CombinedOnCustomDisappearModifier: ViewModifier {
	@Environment(\.customAppear) var customAppear
	@AppStorage(SettingsView.showNewSidebarKey) var showNewSidebar: Bool = true
	
	let perform: () -> Void

	func body(content: Content) -> some View {
		content
			.onDisappear {
				if !showNewSidebar {
					perform()
				}
			}
			.onCustomDisappear {
				if showNewSidebar {
					perform()
				}
			}
	}
}

extension View {
	func onCombinedCustomAppear(perform: @escaping () -> Void) -> some View {
		modifier(CombinedOnCustomAppearModifier(perform: perform))
	}
	
	func onCombinedCustomDisappear(perform: @escaping () -> Void) -> some View {
		modifier(CombinedOnCustomDisappearModifier(perform: perform))
	}
}
