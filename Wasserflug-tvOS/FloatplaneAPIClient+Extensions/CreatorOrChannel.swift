import Foundation
import FloatplaneAPIClient

protocol CreatorOrChannel {
	var id: String { get }
	var title: String { get }
	var about: String { get }
	var cover: ImageModel? { get }
	var icon: ImageModel { get }
	
	var creatorId: String { get }
	var channelId: String? { get }
	var aboutFixed: String { get }
}

extension CreatorModelV3: CreatorOrChannel {
	var creatorId: String {
		id
	}
	var channelId: String? {
		nil
	}
	var aboutFixed: String {
		about.replacingOccurrences(of: "\n\n", with: " ")
	}
}

extension ChannelModel: CreatorOrChannel {
	var creatorId: String {
		creator
	}
	var channelId: String? {
		id
	}
	var aboutFixed: String {
		about.replacingOccurrences(of: "\n\n", with: " ")
	}
}

struct AnyCreatorOrChannel: CreatorOrChannel, Hashable {
	private let creatorOrChannel: CreatorOrChannel
	
	var id: String { creatorOrChannel.id }
	var title: String { creatorOrChannel.title }
	var about: String { creatorOrChannel.about }
	var cover: ImageModel? { creatorOrChannel.cover }
	var icon: ImageModel { creatorOrChannel.icon }
	var creatorId: String { creatorOrChannel.creatorId }
	var channelId: String? { creatorOrChannel.channelId }
	var aboutFixed: String { creatorOrChannel.aboutFixed }
	
	init(_ creatorOrChannel: CreatorOrChannel) {
		self.creatorOrChannel = creatorOrChannel
	}
	
	static func == (lhs: AnyCreatorOrChannel, rhs: AnyCreatorOrChannel) -> Bool {
		return lhs.id == rhs.id &&
		lhs.title == rhs.title &&
		lhs.about == rhs.about &&
		lhs.cover == rhs.cover &&
		lhs.icon == rhs.icon &&
		lhs.creatorId == rhs.creatorId &&
		lhs.channelId == rhs.channelId &&
		lhs.aboutFixed == rhs.aboutFixed
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(title)
		hasher.combine(about)
		hasher.combine(cover)
		hasher.combine(icon)
		hasher.combine(creatorId)
		hasher.combine(channelId)
		hasher.combine(aboutFixed)
	}
}
