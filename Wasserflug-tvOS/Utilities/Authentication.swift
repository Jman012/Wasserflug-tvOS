import Foundation
import FloatplaneAPIClient
import Vapor

extension FloatplaneAPIClientAPI {
	
	private static var FloatplaneURL = URL(string: "https://www.floatplane.com")!
	private static var SailsSidCookieName = "sails.sid"
	
	public static var rawCookie: String = ""
	
	static func loadAuthenticationCookiesFromStorage() {
		let storedCookies = HTTPCookieStorage.shared.cookies(for: FloatplaneURL)
		if let sailsSidCookie = storedCookies?.first(where: { $0.name == SailsSidCookieName }) {
			FloatplaneAPIClientAPI.customHeaders.cookie = [
				SailsSidCookieName: Vapor.HTTPCookies.Value(string: sailsSidCookie.value)
			]
			rawCookie = sailsSidCookie.name + "=" + sailsSidCookie.value
		}
	}
	
	static func storeAuthentifcationCookies(from clientResponse: ClientResponse) {
		if let sailsSidCookie = clientResponse.headers.setCookie?[SailsSidCookieName] {
			FloatplaneAPIClientAPI.customHeaders.cookie = [SailsSidCookieName: sailsSidCookie]
			let httpCookie = HTTPCookie(properties: [
				.domain: "www.floatplane.com",
				.path: "/",
				.name: SailsSidCookieName,
				.value: sailsSidCookie.string,
				.secure: "Secure",
				.expires: NSDate(timeIntervalSince1970: sailsSidCookie.expires!.timeIntervalSince1970),
			])
			HTTPCookieStorage.shared.setCookies([httpCookie!], for: FloatplaneURL, mainDocumentURL: nil)
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
