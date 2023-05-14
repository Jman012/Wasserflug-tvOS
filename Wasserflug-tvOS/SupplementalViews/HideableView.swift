import SwiftUI


extension View {
	func hide(_ hide: Bool) -> some View {
		HideableView(isHidden: .constant(hide), view: self)
	}
	
	func hide(_ isHidden: Binding<Bool>) -> some View {
		HideableView(isHidden: isHidden, view: self)
	}
}

// With love, and modifications, from
// https://hfossli.medium.com/hiding-and-unhiding-views-in-swiftui-9474a839e5c9
// This is a life saver <3
struct HideableView<Content: View>: UIViewRepresentable {
	
	@Environment(\.self) private var env
	@Binding var isHidden: Bool
	var view: Content
	
	func makeUIView(context: Context) -> ViewContainer {
		return ViewContainer(isContentHidden: isHidden, child: AnyView(view.environment(\.self, env)))
	}
	
	func updateUIView(_ container: ViewContainer, context: Context) {
		container.child.rootView = AnyView(view.environment(\.self, env))
		container.isContentHidden = isHidden
	}
	
	class ViewContainer: UIView {
		var child: UIHostingController<AnyView>
		var didShow = false
		var isContentHidden: Bool {
			didSet {
				addOrRemove()
			}
		}
		
		init(isContentHidden: Bool, child: AnyView) {
			self.child = UIHostingController(rootView: child)
			self.isContentHidden = isContentHidden
			super.init(frame: .zero)
			addOrRemove()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func layoutSubviews() {
			super.layoutSubviews()
			child.view.frame = bounds
		}
		
		func addOrRemove() {
			if isContentHidden && child.view.superview != nil {
				child.view.removeFromSuperview()
			}
			if !isContentHidden && child.view.superview == nil {
				if !didShow {
					DispatchQueue.main.async {
						if !self.isContentHidden {
							self.addSubview(self.child.view)
							self.didShow = true
						}
					}
				} else {
					addSubview(child.view)
				}
			}
		}
		
	}
}
