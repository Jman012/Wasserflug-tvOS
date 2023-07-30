import SwiftUI

extension View {
	@ViewBuilder func optionalPrefersDefaultFocus(in namespace: Namespace.ID?) -> some View {
		if let namespace {
			self
				.prefersDefaultFocus(in: namespace)
		} else {
			self
		}
	}
}
