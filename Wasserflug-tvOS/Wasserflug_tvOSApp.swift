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
		logger.logLevel = .info
		#else
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
	
	init() {
		FloatplaneAPIClientAPI.customHeaders.replaceOrAdd(name: "User-Agent", value: "Wasserflug tvOS App, CFNetwork")
		FloatplaneAPIClientAPI.loadAuthenticationCookiesFromStorage()
		
		// Use FP's date format for JSON encoding/decoding.
		let fpDateFormatter = DateFormatter()
		fpDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		Configuration.contentConfiguration.use(encoder: JSONEncoder.custom(dates: .formatted(fpDateFormatter)), for: .json)
		Configuration.contentConfiguration.use(decoder: JSONDecoder.custom(dates: .formatted(fpDateFormatter)), for: .json)
		
		// Logging
		LoggingSystem.bootstrap({ (label) -> LogHandler in
			var loggingLogger = OSLoggingLogger(label: label, category: "Wasserflug")
			loggingLogger.logLevel = .debug
			return MultiplexLogHandler([
				loggingLogger,
			])
		})
		
		// API/Network Logging
		Configuration.apiClient = vaporApp.client
			.logging(to: Wasserflug_tvOSApp.networkLogger)
		Configuration.apiWrapper = { clientRequest in
			Wasserflug_tvOSApp.networkLogger.info("Sending \(clientRequest.method) request to \(clientRequest.url)")
		}
		
		authViewModel = AuthViewModel(fpApiService: fpApiService)
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: authViewModel)
				.environment(\.fpApiService, fpApiService)
		}
	}
}
