import Foundation
import SwiftUI

fileprivate extension Notification.Name {
	static let wasserflugToast = Notification.Name("WasserflugToast")
}

struct Toast: Identifiable, Hashable {
	let id: UUID = UUID()
	let message: String
	
	init(_ item: WasserflugToast) {
		self.message = item.message
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
	
	private var publisher = NotificationCenter.default
			.publisher(for: .wasserflugToast)
			.compactMap { notification in
				return notification.object as? Toast
			}
			.receive(on: RunLoop.main)
	
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
		.onReceive(publisher, perform: { toast in
			toasts.insert(toast, at: 0)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				withAnimation {
					self.toasts.removeAll(where: { $0.id == toast.id })
				}
			}
		})
	}
}
