import SwiftUI

struct ExecuteCode : View {
	init(_ codeToExec: () -> Void) {
		codeToExec()
	}
	
	var body: some View {
		return Rectangle().fill(.clear)
	}
}
