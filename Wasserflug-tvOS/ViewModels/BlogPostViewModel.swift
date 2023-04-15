import Foundation
import FloatplaneAPIClient
import NIO
import UIKit
import SwiftUI

class BlogPostViewModel: BaseViewModel, ObservableObject {
	@Published var state: ViewModelState<ContentPostV3Response> = .idle
	
	private let fpApiService: FPAPIService
	let id: String
	
	var textAttributedString: AttributedString = AttributedString()
	@Published var latestUserInteraction: [String]? = nil
	
	var isLiked: Bool {
		guard case let .loaded(content) = state else {
			return false
		}
		if let latest = latestUserInteraction {
			return latest.contains("like")
		} else {
			return content.userInteraction?.contains(.like) ?? false
		}
	}
	
	var isDisliked: Bool {
		guard case let .loaded(content) = state else {
			return false
		}
		if let latest = latestUserInteraction {
			return latest.contains("dislike")
		} else {
			return content.userInteraction?.contains(.dislike) ?? false
		}
	}
	
	init(fpApiService: FPAPIService, id: String, state: ViewModelState<ContentPostV3Response> = .idle) {
		self.fpApiService = fpApiService
		self.id = id
		self.state = state
		
		// for swiftui previews
		super.init()
		if case let .loaded(blogPost) = state {
			self.textAttributedString = self.convertDescriptionToAttributeString(blogPost.text, colorScheme: .dark)
		}
	}
	
	func load(colorScheme: ColorScheme) {
		state = .loading
		
		logger.info("Loading blog post information.", metadata: [
			"id": "\(id)",
		])
		
		fpApiService
			.getBlogPost(id: id)
			.flatMapResult { (response) -> Result<ContentPostV3Response, Error> in
				switch response {
				case let .http200(value: blogPost, raw: clientResponse):
					self.logger.debug("Blog post raw response: \(clientResponse.plaintextDebugContent)")
					return .success(blogPost)
				case let .http0(value: errorModel, raw: clientResponse),
					let .http400(value: errorModel, raw: clientResponse),
					let .http401(value: errorModel, raw: clientResponse),
					let .http403(value: errorModel, raw: clientResponse),
					let .http404(value: errorModel, raw: clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading the blog post. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				case .http429(raw: _):
					self.logger.warning("Received HTTP 429 Too Many Requests.")
					return .failure(WasserflugError.http429)
				}
			}
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(blogPost):
						self.logger.notice("Received blog post information.", metadata: [
							"id": "\(blogPost.id)",
							"title": "\(blogPost.title)",
							"attachments": "\(blogPost.attachmentOrder.joined(separator: ", "))",
						])
						self.textAttributedString = self.convertDescriptionToAttributeString(blogPost.text, colorScheme: colorScheme)
						self.state = .loaded(blogPost)
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading the blog post. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.state = .failed(error)
					}
				}
			}
	}
	
	func convertDescriptionToAttributeString(_ description: String, colorScheme: ColorScheme) -> AttributedString {
		let nsAttributedStringDescription = try! NSMutableAttributedString(
			data: description.data(using: .utf8)!,
			options: [
				.documentType: NSAttributedString.DocumentType.html,
				.characterEncoding: String.Encoding.utf8.rawValue,
			],
			documentAttributes: nil)
		let attributeOverrides = [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0),
			NSAttributedString.Key.foregroundColor: colorScheme == .light ? UIColor.black : UIColor.white,
		]
		nsAttributedStringDescription.addAttributes(attributeOverrides, range: NSRange(location: 0, length: nsAttributedStringDescription.length))
		
		return AttributedString(nsAttributedStringDescription)
	}
	
	func like() {
		logger.info("Performing a like interaction on the blog post.", metadata: [
			"id": "\(id)",
		])
		fpApiService
			.likeContent(id: id)
			.flatMapResult({ (response) -> Result<[String], Error> in
				switch response {
				case let .http200(value: result, raw: clientResponse):
					self.logger.debug("Like raw response: \(clientResponse.plaintextDebugContent)")
					return .success(result)
				case let .http0(value: errorModel, raw: clientResponse),
					let .http400(value: errorModel, raw: clientResponse),
					let .http401(value: errorModel, raw: clientResponse),
					let .http403(value: errorModel, raw: clientResponse),
					let .http404(value: errorModel, raw: clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while liking the blog post. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				case .http429(raw: _):
					self.logger.warning("Received HTTP 429 Too Many Requests.")
					return .failure(WasserflugError.http429)
				}
			})
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						self.logger.notice("Finished liking the blog post.", metadata: [
							"id": "\(self.id)",
							"response": "\(response.joined(separator: ", "))",
						])
						self.latestUserInteraction = response
					default:
						break
					}
				}
			}
	}
	
	func dislike() {
		logger.info("Performing a dislike interaction on the blog post.", metadata: [
			"id": "\(id)",
		])
		fpApiService
			.dislikeContent(id: id)
			.flatMapResult({ (response) -> Result<[String], Error> in
				switch response {
				case let .http200(value: result, raw: clientResponse):
					self.logger.debug("Dislike raw response: \(clientResponse.plaintextDebugContent)")
					return .success(result)
				case let .http0(value: errorModel, raw: clientResponse),
					let .http400(value: errorModel, raw: clientResponse),
					let .http401(value: errorModel, raw: clientResponse),
					let .http403(value: errorModel, raw: clientResponse),
					let .http404(value: errorModel, raw: clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while disliking the blog post. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				case .http429(raw: _):
					self.logger.warning("Received HTTP 429 Too Many Requests.")
					return .failure(WasserflugError.http429)
				}
			})
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						self.logger.notice("Finished disliking the blog post.", metadata: [
							"id": "\(self.id)",
							"response": "\(response.joined(separator: ", "))",
						])
						self.latestUserInteraction = response
					default:
						break
					}
				}
			}
	}
}

