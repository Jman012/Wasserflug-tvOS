import SwiftUI
import FloatplaneAPIClient
import Vapor
import os
import Logging

@main
struct Wasserflug_tvOSApp: App {
	static var logger: Logging.Logger {
		var logger = Logging.Logger(label: Bundle.main.bundleIdentifier!)
		#if DEBUG
		// For debugging, log at a lower level to get more information.
		logger.logLevel = .debug
		#else
		// For release mode, only log important items.
		logger.logLevel = .notice
		#endif
		return logger
	}
	static var networkLogger: Logging.Logger {
		var logger = Logging.Logger(label: Bundle.main.bundleIdentifier!)
		logger.logLevel = .info
		logger[metadataKey: "category"] = "network"
		return logger
	}
	
	let vaporApp = Vapor.Application(.production, .createNew)
	let fpApiService: FPAPIService = DefaultFPAPIService()
	let authViewModel: AuthViewModel
	let persistenceController = PersistenceController.shared
	
	init() {
		// Set custom user agent for network requests. This is particularly
		// required in order to pass the login phase with bypassing the captcha.
		Wasserflug_tvOSApp.setHttp(header: "User-Agent", value: "Wasserflug tvOS App, CFNetwork")
		
		// Attempt to use any previous authentication cookies, so the user does
		// not need to login on every app start.
		FloatplaneAPIClientAPI.loadAuthenticationCookiesFromStorage()
		
		// Use FP's date format for JSON encoding/decoding.
		let fpDateFormatter = DateFormatter()
		fpDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		Configuration.contentConfiguration.use(encoder: JSONEncoder.custom(dates: .formatted(fpDateFormatter)), for: .json)
		Configuration.contentConfiguration.use(decoder: JSONDecoder.custom(dates: .formatted(fpDateFormatter)), for: .json)
		
		// Bootstrap core logging.
		LoggingSystem.bootstrap({ (label) -> LogHandler in
			var loggingLogger = OSLoggingLogger(label: label, category: "Wasserflug")
			loggingLogger.logLevel = .debug
			return MultiplexLogHandler([
				loggingLogger,
			])
		})
		
		// Bootstrap API/Network logging.
		Configuration.apiClient = vaporApp.client
			.logging(to: Wasserflug_tvOSApp.networkLogger)
		Configuration.apiWrapper = { clientRequest in
			Wasserflug_tvOSApp.networkLogger.info("Sending \(clientRequest.method) request to \(clientRequest.url)")
		}
		
		// Create and store in @State the main view model.
		authViewModel = AuthViewModel(fpApiService: fpApiService)
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: authViewModel)
				.environment(\.fpApiService, fpApiService)
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
	
	private static func setHttp(header: String, value: String) {
		FloatplaneAPIClientAPI.customHeaders.replaceOrAdd(name: header, value: value)
		if var headers = URLSession.shared.configuration.httpAdditionalHeaders {
			headers[header] = value
			URLSession.shared.configuration.httpAdditionalHeaders = headers
		} else {
			URLSession.shared.configuration.httpAdditionalHeaders = [
				header: value,
			]
		}
	}
}
