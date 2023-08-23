import Foundation
import SwiftUI

struct ControlSocketOn: OptionSet {
	let rawValue: Int
	
	static let onAppear = ControlSocketOn(rawValue: 1 << 0)
	static let onDisappear = ControlSocketOn(rawValue: 1 << 1)
	static let onSceneActive = ControlSocketOn(rawValue: 1 << 2)
	static let onSceneInactive = ControlSocketOn(rawValue: 1 << 3)
	static let onSceneBackground = ControlSocketOn(rawValue: 1 << 4)
}

struct ControlSocketModifier<Socket>: ViewModifier where Socket : FPSocket {
	@Environment(\.scenePhase) var scenePhase
	let fpSocket: Socket
	let on: ControlSocketOn
	
	func body(content: Content) -> some View {
		return content
			.onAppear {
				if on.contains(.onAppear) {
					fpSocket.connect()
				}
			}.onDisappear {
				if on.contains(.onDisappear) {
					fpSocket.disconnect()
				}
			}.onChange(of: scenePhase, perform: { phase in
				switch phase {
				case .active:
					if on.contains(.onSceneActive) {
						fpSocket.connect()
					}
				case .inactive:
					if on.contains(.onSceneInactive) {
						fpSocket.disconnect()
					}
				case .background:
					if on.contains(.onSceneBackground) {
						fpSocket.disconnect()
					}
				@unknown default:
					break
				}
			})
	}
}

extension View {
	func fpSocketControlSocket<Socket>(_ fpSocket: Socket, on: ControlSocketOn) -> some View where Socket : FPSocket {
		return self
			.modifier(ControlSocketModifier(fpSocket: fpSocket, on: on))
	}
}
