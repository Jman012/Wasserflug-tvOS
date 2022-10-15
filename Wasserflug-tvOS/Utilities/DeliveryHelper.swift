import Foundation
import AnyCodable
import FloatplaneAPIClient

let rgxTemplateItemPattern = try! NSRegularExpression(pattern: #"\{([0-9a-z._$]*)\}"#, options: .caseInsensitive)

class DeliveryHelper {
	class func getBestUrl(variant: CdnDeliveryV3Variant, group: CdnDeliveryV3Group?) -> URL? {
		// If the variant itself has an absolute URL, use that.
		if let absoluteUrl = URL(string: variant.url), absoluteUrl.host != nil {
			return absoluteUrl
		}
		
		// Otherwise, get the best URL, in order of:
		// 1. First try the variant's origins, if any
		// 2. Try the group's origins, if any
		// 3. Lastly, default to floatplane.com
		
		if let variantOrigins = variant.origins {
			for randomElement in variantOrigins.shuffled() {
				if let url = joinUrl(base: randomElement.url, remainder: variant.url) {
					return url
				}
			}
		}
		
		if let groupOrigins = group?.origins {
			for randomElement in groupOrigins.shuffled() {
				if let url = joinUrl(base: randomElement.url, remainder: variant.url) {
					return url
				}
			}
		}
		
		return joinUrl(base: "https://www.floatplane.com", remainder: variant.url)
	}
	
	private class func joinUrl(base: String, remainder: String) -> URL? {
		let cleanBase = base.trimmingSuffix(while: { $0 == "/" })
		if remainder.hasPrefix("/") {
			return URL(string: String(cleanBase) + String(remainder))
		} else {
			return URL(string: String(cleanBase) + "/" + String(remainder))
		}
	}
}
