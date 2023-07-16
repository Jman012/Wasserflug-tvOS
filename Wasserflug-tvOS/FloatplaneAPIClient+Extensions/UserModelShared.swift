import Foundation
import FloatplaneAPIClient

protocol UserModelShared {
	var id: String { get }
	var username: String { get }
	var profileImage: ImageModel { get }
}

extension UserModel: UserModelShared {
}

extension UserSelfModel: UserModelShared {
}

struct AnyUserModelShared: UserModelShared, Hashable {
	private let userModelShared: UserModelShared
	
	var id: String { userModelShared.id }
	var username: String { userModelShared.username }
	var profileImage: ImageModel { userModelShared.profileImage }
	
	init(_ userModelShared: UserModelShared) {
		self.userModelShared = userModelShared
	}
	
	static func == (lhs: AnyUserModelShared, rhs: AnyUserModelShared) -> Bool {
		return lhs.id == rhs.id && lhs.username == rhs.username && lhs.profileImage == rhs.profileImage
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(username)
		hasher.combine(profileImage)
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
