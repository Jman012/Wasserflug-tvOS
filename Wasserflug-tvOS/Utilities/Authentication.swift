import Foundation
import FloatplaneAPIClient
import Vapor

extension FloatplaneAPIClientAPI {
	
	private static var FloatplaneURL = URL(string: "https://www.floatplane.com")!
	private static var SailsSidCookieName = "sails.sid"
	
	public static var rawCookieValue: String = ""
	
	static func loadAuthenticationCookiesFromStorage() {
		let storedCookies = HTTPCookieStorage.shared.cookies(for: FloatplaneURL)
		if let sailsSidCookie = storedCookies?.first(where: { $0.name == SailsSidCookieName }) {
			FloatplaneAPIClientAPI.customHeaders.cookie = [
				SailsSidCookieName: Vapor.HTTPCookies.Value(string: sailsSidCookie.value),
			]
			rawCookieValue = sailsSidCookie.value
			
			// Cookies were previously stored for `www.floatplane.com` instead of `.floatplane.com`.
			// On app startup/loading auth cookies, detect if this cookie is old and re-save it
			// with the proper domain
			if sailsSidCookie.domain == "www.floatplane.com" {
				HTTPCookieStorage.shared.deleteCookie(sailsSidCookie)
				let newSailsSidCookie = HTTPCookie(properties: [
					.domain: ".floatplane.com",
					.path: "/",
					.name: SailsSidCookieName,
					.value: sailsSidCookie.value,
					.secure: "Secure",
					.expires: sailsSidCookie.expiresDate as Any,
				])!
				HTTPCookieStorage.shared.setCookies([newSailsSidCookie], for: FloatplaneURL, mainDocumentURL: nil)
			}
		}
	}
	
	static func storeAuthentifcationCookies(from clientResponse: ClientResponse) {
		if let sailsSidCookie = clientResponse.headers.setCookie?[SailsSidCookieName] {
			FloatplaneAPIClientAPI.customHeaders.cookie = [SailsSidCookieName: sailsSidCookie]
			let httpCookie = HTTPCookie(properties: [
				.domain: ".floatplane.com",
				.path: "/",
				.name: SailsSidCookieName,
				.value: sailsSidCookie.string,
				.secure: "Secure",
				.expires: NSDate(timeIntervalSince1970: sailsSidCookie.expires!.timeIntervalSince1970),
			])
			HTTPCookieStorage.shared.setCookies([httpCookie!], for: FloatplaneURL, mainDocumentURL: nil)
			rawCookieValue = sailsSidCookie.string
		}
	}
	
	static func removeAuthenticationCookies() {
		let storedCookies = HTTPCookieStorage.shared.cookies(for: FloatplaneURL)
		if let sailsSidCookie = storedCookies?.first(where: { $0.name == SailsSidCookieName }) {
			HTTPCookieStorage.shared.deleteCookie(sailsSidCookie)
		}
		FloatplaneAPIClientAPI.customHeaders.cookie = [:]
	}
}
