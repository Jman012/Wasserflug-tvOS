import Foundation
import CoreGraphics
import FloatplaneAPIClient

extension ErrorModel: LocalizedError {
	public var errorDescription: String? {
		let message = self.message ?? self.errors.first?.message ?? self.errors.first?.name ?? "Error message unretrievable."
		let separator: String
		if message.last != "." {
			separator = ". "
		} else {
			separator = " "
		}
		return message + separator + "Error ID: " + self.id
	}
	
	public var failureReason: String? {
		nil
	}

	public var recoverySuggestion: String? {
		nil
	}

	public var helpAnchor: String? {
		nil
	}
}

extension VideoAttachmentModel: Identifiable { }

extension PictureAttachmentModel: Identifiable { }

extension BlogPostModelV3: Identifiable { }

extension UserSubscriptionModel: Identifiable {
	public var id: String {
		self.creator
	}
}

extension ImageModel {
	var aspectRatio: CGFloat {
		return CGFloat(self.width) / CGFloat(self.height)
	}
}
