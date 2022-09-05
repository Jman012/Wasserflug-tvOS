import SwiftUI

struct ExecuteCode : View {
	init( _ codeToExec: () -> () ) {
		codeToExec()
	}
	
	var body: some View {
		return Rectangle().fill(.clear)
	}
}

