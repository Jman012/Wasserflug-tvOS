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
