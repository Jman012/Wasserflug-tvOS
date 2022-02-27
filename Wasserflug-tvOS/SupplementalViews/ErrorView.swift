import SwiftUI
import FloatplaneAPIClient

struct ErrorView: View {
	let error: Error
	var body: some View {
		VStack {
			if error is ErrorModel {
				Text("An error was encountered while communicating with Floatplane:\n")
				Text(error.localizedDescription)
				Text("\nPlease try again. If you believe this is a bug, please file a report with the app developer, *NOT* with Floatplane staff.")
			} else {
				Text("An unexpected error was encountered while processing your data. Please submit a bug report with the app developer, *NOT* with Floatplane staff.\nError information:\n")
				Text(error.localizedDescription)
			}
		}
			.font(.headline)
			.multilineTextAlignment(.center)
	}
}

struct ErrorView_Previews: PreviewProvider {
	static var previews: some View {
		ErrorView(error: ErrorModel(id: "test id", errors: [.init(id: "test id 2", name: "test name", message: "test message", data: nil)], message: "test error message"))
	}
}
