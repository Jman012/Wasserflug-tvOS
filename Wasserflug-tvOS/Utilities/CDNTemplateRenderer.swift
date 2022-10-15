import Foundation
import AnyCodable
import FloatplaneAPIClient

let rgxTemplateItemPattern = try! NSRegularExpression(pattern: #"\{([0-9a-z._$]*)\}"#, options: .caseInsensitive)

class CDNTemplateRenderer {
	class func render(template: String, data: CdnDeliveryV2ResourceModelData, quality: CdnDeliveryV2QualityLevelModel) -> String {
		var newTemplate = template
		for match in rgxTemplateItemPattern.matches(in: template, range: NSRange(location: 0, length: template.count)) {
			guard let outerRange = Range(match.range(at: 0), in: template),
					let innerRange = Range(match.range(at: 1), in: template) else {
				continue
			}
			let source = template[outerRange]
			let replace = getDataValueFromKeyPath(path: String(template[innerRange]), data: data, quality: quality)
				.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.union(.urlQueryAllowed)) ?? ""
			
			newTemplate = newTemplate.replacingOccurrences(of: source, with: replace)
		}
		
		return newTemplate
	}
	
	class func getDataValueFromKeyPath(path: String, data: CdnDeliveryV2ResourceModelData, quality: CdnDeliveryV2QualityLevelModel) -> String {
		let components = path.split(separator: ".")
		var replace: Any? = nil
		for (index, component) in components.enumerated() {
			switch (index, component) {
			case  (0, "qualityLevels"):
				if components.count == 1 {
					return quality.name
				} else {
					replace = quality
				}
			case (0, "qualityLevelParams"):
				replace = data.qualityLevelParams?[quality.name]?.value
			case (0, _):
				replace = data.additionalProperties[String(component)]?.value
			default:
				if let currentReplace = replace as? CdnDeliveryV2QualityLevelModel {
					switch String(component).lowercased() {
					case "name":
						replace = currentReplace.name
					case "width":
						replace = currentReplace.width
					case "height":
						replace = currentReplace.height
					case "label":
						replace = currentReplace.label
					case "order":
						replace = currentReplace.order
					case "mimeType".lowercased():
						replace = currentReplace.mimeType
					case "codecs":
						replace = currentReplace.codecs
					default:
						break
					}
				} else if let currentReplace = replace as? [String: AnyCodable] {
					replace = currentReplace[String(component)]?.value
				} else if let currentReplace = replace as? [String: Any] {
					replace = currentReplace[String(component)]
				}
			}
		}
		
		if let result = replace as? String {
			return result
		} else {
			return ""
		}
	}
}
