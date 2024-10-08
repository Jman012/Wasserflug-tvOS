import SwiftUI

extension View {
	func innerShadow(color: Color, radius: CGFloat = 10, edges: Edge.Set = .all) -> some View {
		modifier(InnerShadow(color: color, radius: radius, edges: edges))
	}
}

private struct InnerShadow: ViewModifier {
	var color: Color = .gray
	var radius: CGFloat = 10
	var edges: Edge.Set

	private var colors: [Color] {
		[color.opacity(0.25), color.opacity(0.0)]
	}

	func body(content: Content) -> some View {
		content
			.background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .top, endPoint: .bottom)
				.frame(height: self.radius)
				.opacity(edges.contains(.top) ? 1.0 : 0.0),
				alignment: .top)
			.background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .bottom, endPoint: .top)
				.frame(height: self.radius)
				.opacity(edges.contains(.bottom) ? 1.0 : 0.0),
				alignment: .bottom)
			.background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .leading, endPoint: .trailing)
				.frame(width: self.radius)
				.opacity(edges.contains(.leading) ? 1.0 : 0.0),
				alignment: .leading)
			.background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .trailing, endPoint: .leading)
				.frame(width: self.radius)
				.opacity(edges.contains(.trailing) ? 1.0 : 0.0),
				alignment: .trailing)
	}
}
