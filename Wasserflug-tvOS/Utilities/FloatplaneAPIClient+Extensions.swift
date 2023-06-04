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

protocol ImageModelShared {
	var width: Int { get set }
	var height: Int { get set }
	var path: String { get set }
	var childImages: [ChildImageModel]? { get set }
}

extension ImageModelShared {
	var aspectRatio: CGFloat {
		return CGFloat(self.width) / CGFloat(self.height)
	}
}

extension ImageModel: ImageModelShared {
	
}

extension Optional where Wrapped == ImageModelShared {
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

protocol UserModelShared {
	var id: String { get }
	var username: String { get }
	var profileImage: ImageModel { get }
}

extension UserModel: UserModelShared {
	
}

extension UserSelfModel: UserModelShared {
	
}

struct AnyUserModelShared: UserModelShared {
	private let userModelShared: UserModelShared
	
	var id: String {
		return userModelShared.id
	}
	
	var username: String {
		return userModelShared.username
	}
	
	var profileImage: ImageModel {
		return userModelShared.profileImage
	}
	
	init(_ userModelShared: UserModelShared) {
		self.userModelShared = userModelShared
	}
}

extension AnyUserModelShared: Equatable {
	static func == (lhs: AnyUserModelShared, rhs: AnyUserModelShared) -> Bool {
		return lhs.id == rhs.id && lhs.username == rhs.username && lhs.profileImage == rhs.profileImage
	}
}

extension UserModelShared {
	func asAnyUserModelShared() -> AnyUserModelShared {
		return AnyUserModelShared(self)
	}
}

extension UserInfoV2ResponseUsersInnerUser {
	var userModelShared: UserModelShared {
		switch self {
		case let .typeUserModel(userModel):
			return userModel
		case let .typeUserSelfModel(userSelfModel):
			return userSelfModel
		}
	}
}

extension CreatorModelV3Owner {
	var id: String {
		switch self {
		case let .typeCreatorModelV3OwnerOneOf(owner):
			return owner.id!
		case let .typeString(id):
			return id
		}
	}
}
