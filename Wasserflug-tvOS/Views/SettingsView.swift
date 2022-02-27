import SwiftUI
import FloatplaneAPIClient

struct SettingsView: View {
	
	var body: some View {
		VStack {
			Button(action: {
				FloatplaneAPIClientAPI.removeAuthenticationCookies()
				NotificationCenter.default.post(name: ContentView.Notifications.loggedOut, object: nil)
			}, label: {
				Text("Logout")
			})
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
