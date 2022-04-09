import SwiftUI
import CoreData
import Logging
import FloatplaneAPIClient

struct SettingsView: View {
	@Namespace var namespace
	@Environment(\.managedObjectContext) private var viewContext
	
	@State var showResetViewHistoryConfirmation = false
	@State var showResetViewHistorySuccess = false
	@State var showResetViewHistoryFailure = false
	
	let logger: Logger = {
		var logger = Wasserflug_tvOSApp.logger
		logger[metadataKey: "class"] = "\(Self.Type.self)"
		return logger
	}()
	
	var body: some View {
		VStack {
			Button(action: {
				FloatplaneAPIClientAPI.removeAuthenticationCookies()
				NotificationCenter.default.post(name: ContentView.Notifications.loggedOut, object: nil)
			}, label: {
				Text("Logout")
			})
				.prefersDefaultFocus(in: namespace)
			
			Button(action: {
				showResetViewHistoryConfirmation = true
			}, label: {
				Text("Reset View History")
			})
				.confirmationDialog("Reset View History", isPresented: $showResetViewHistoryConfirmation, actions: {
					Button("Reset", role: .destructive, action: {

						let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WatchProgress.fetchRequest()
						let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
						do {
							try viewContext.execute(deleteRequest)
							showResetViewHistorySuccess = true
						} catch {
							logger.error("Error resetting view history: \(String(reflecting: error))")
							showResetViewHistoryFailure = true
						}

						showResetViewHistoryConfirmation = false
					})
				}, message: {
					Text("This will remove all view history from this device. This can not be undone. Are you sure you want to continue?")
				})
				.alert("Resetting View History Successful", isPresented: $showResetViewHistorySuccess, actions: {})
				.alert("Resetting View History Failed", isPresented: $showResetViewHistoryFailure, actions: {})
		}
			.focusScope(namespace)
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
