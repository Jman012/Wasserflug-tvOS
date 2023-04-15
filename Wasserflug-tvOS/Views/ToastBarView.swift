import Foundation
import SwiftUI

fileprivate extension Notification.Name {
	static let wasserflugToast = Notification.Name("WasserflugToast")
}

struct Toast: Identifiable, Hashable {
	let id: UUID = UUID()
	let message: String
	let wasserflugToast: WasserflugToast?
	
	init(_ item: WasserflugToast) {
		self.message = item.message
		self.wasserflugToast = item
	}
	
	static func post(toast: Toast) {
		NotificationCenter.default.post(name: .wasserflugToast, object: toast)
	}
}

enum WasserflugToast {
	case failedToLoadProgress
	
	var message: String {
		switch self {
		case .failedToLoadProgress:
			return "Watch progress unavailable"
		}
	}
}

struct ToastBarView: View {
	
	@State var toasts: [Toast] = []
	@State var lastToastRecievedOf: [WasserflugToast: Date] = [:]
	
	var body: some View {
		VStack {
			ForEach(toasts) { toast in
				Text(toast.message)
					.padding()
					.background(VisualEffectView(effect: UIBlurEffect(style: .light)))
					.cornerRadius(20)
					.transition(.asymmetric(insertion: .opacity, removal: .slide))
			}
		}
		.animation(.easeInOut, value: toasts)
		.onReceive(NotificationCenter.default
			.publisher(for: .wasserflugToast)
			.compactMap { (notification) -> Toast? in
				let toast = notification.object as? Toast
				if let wasserflugToast = toast?.wasserflugToast {
					// Skip excess failedToLoadProgress toasts if received within 5 minutes of the initial one.
					if let lastReceived = lastToastRecievedOf[wasserflugToast], wasserflugToast == .failedToLoadProgress && lastReceived.timeIntervalSinceNow < TimeInterval(5 * 60) {
						return nil
					}
					lastToastRecievedOf[wasserflugToast] = Date()
					return toast
				}
				return toast
			}
			.receive(on: RunLoop.main), perform: { toast in
			toasts.insert(toast, at: 0)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				withAnimation {
					self.toasts.removeAll(where: { $0.id == toast.id })
				}
			}
		})
	}
}
