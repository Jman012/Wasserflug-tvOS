//import SwiftUI
//
//
//extension View {
//	func hide2(_ hide: Bool) -> some View {
//		HideableView2(isHidden: .constant(hide), view: self)
//	}
//	
//	func hide2(_ isHidden: Binding<Bool>) -> some View {
//		HideableView2(isHidden: isHidden, view: self)
//	}
//}
//
//// With love from https://hfossli.medium.com/hiding-and-unhiding-views-in-swiftui-9474a839e5c9
//// <3
//// This is a life saver
//struct HideableView2<Content: View>: UIViewControllerRepresentable {
//	typealias UIViewControllerType = ViewContainer<Content>
//	
//	@Binding var isHidden: Bool
//	var view: Content
//	
//	func makeUIViewController(context: Context) -> ViewContainer<Content> {
//		return ViewContainer(isContentHidden: isHidden, child: view)
//	}
//	
//	func updateUIViewController(_ container: ViewContainer<Content>, context: Context) {
//		container.child = view
//		container.isContentHidden = isHidden
//	}
//	
//	class ViewContainer<Content: View>: UIHostingController<Content> {
//		var child: Content
//		var didShow = false
//		var isContentHidden: Bool {
//			didSet {
//				addOrRemove()
//			}
//		}
//		
//		init(isContentHidden: Bool, child: Content) {
//			self.child = child
//			self.isContentHidden = isContentHidden
//			super.init(rootView: child)
//			addOrRemove()
//		}
//		
//		required init?(coder: NSCoder) {
//			fatalError("init(coder:) has not been implemented")
//		}
//		
////		override func layoutSubviews() {
////			super.layoutSubviews()
////			child.view.frame = bounds
////		}
//		
//		func addOrRemove() {
//			if isContentHidden && child.view.superview != nil {
//				child.view.removeFromSuperview()
//			}
//			if !isContentHidden && child.view.superview == nil {
//				if !didShow {
//					DispatchQueue.main.async {
//						if !self.isContentHidden {
//							self.addSubview(self.child.view)
//							self.didShow = true
//						}
//					}
//				} else {
//					addSubview(child.view)
//				}
//			}
//		}
//		
//	}
//}
