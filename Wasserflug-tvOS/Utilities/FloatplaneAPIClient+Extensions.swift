import Foundation
import CoreGraphics
import SwiftUI
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

extension AudioAttachmentModel: Identifiable { }

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

extension Optional where Wrapped == ImageModel {
	var pathUrlOrNil: URL? {
		if let thumbnail = self {
			return URL(string: thumbnail.path)
		} else {
			return nil
		}
	}
	
	func bestImage(for geometrySize: CGSize?) -> URL? {
		guard let self = self, let geometrySize = geometrySize else {
			return nil
		}
		
		let geometryMagnitude = Int(geometrySize.width * geometrySize.height)
		var difference = abs((self.width * self.height) - geometryMagnitude)
		var path = self.path
		
		for childImage in self.childImages ?? [] {
			let childDifference = abs((childImage.width * childImage.height) - geometryMagnitude)
			
			if childDifference < difference {
				difference = childDifference
				path = childImage.path
			}
		}
		
		return URL(string: path)
	}
}
