// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let floatplaneAPIAsyncModels = try? JSONDecoder().decode(FloatplaneAPIAsyncModels.self, from: jsonData)

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// This document serves as a collection of model schemas used in the associated AsyncAPI
// documents. The root level object is only here to reference everything within this
// document so that code generators (such as Quicktype) actually generate everything.

// MARK: - FloatplaneAPIAsyncModels

public struct FloatplaneAPIAsyncModels: Codable, Hashable {
	public let chatUserList: ChatUserList?
	public let childImageModel: ChildImageModel?
	public let creatorMenuUpdate: CreatorMenuUpdate?
	public let creatorNotification: CreatorNotification?
	public let emoteList: [Emote]?
	public let getChatUserList: GetChatUserList?
	public let imageModel: ImageModel?
	public let joinedLiveRoom: JoinedLiveRoom?
	public let joinedLivestreamRadioFrequency: JoinedLivestreamRadioFrequency?
	public let joinLiveRoom: JoinLiveRoom?
	public let joinLivestreamRadioFrequency: JoinLivestreamRadioFrequency?
	public let leaveLiveRoom: LeaveLiveRoom?
	public let leaveLivestreamRadioFrequency: LeaveLivestreamRadioFrequency?
	public let leftLiveRoom: LeftLiveRoom?
	public let leftLivestreamRadioFrequency: LeftLivestreamRadioFrequency?
	public let notificationData: NotificationData?
	public let pollOpenClose: PollOpenClose?
	public let pollUpdateTally: PollUpdateTally?
	public let postRelease: PostRelease?
	public let radioChatter: RadioChatter?
	public let sailsConnect: SailsConnect?
	public let sailsConnected: SailsConnected?
	public let sailsDisonnect: SailsDisconnect?
	public let sailsDisonnected: SailsDisconnected?
	public let sailsHeaders: [String: String]?
	public let sailsStatusCode: Int?
	public let sendLivestreamRadioChatter: SendLivestreamRadioChatter?
	public let sentLivestreamRadioChatter: SentLivestreamRadioChatter?

	enum CodingKeys: String, CodingKey {
		case chatUserList = "ChatUserList"
		case childImageModel = "ChildImageModel"
		case creatorMenuUpdate = "CreatorMenuUpdate"
		case creatorNotification = "CreatorNotification"
		case emoteList = "EmoteList"
		case getChatUserList = "GetChatUserList"
		case imageModel = "ImageModel"
		case joinedLiveRoom = "JoinedLiveRoom"
		case joinedLivestreamRadioFrequency = "JoinedLivestreamRadioFrequency"
		case joinLiveRoom = "JoinLiveRoom"
		case joinLivestreamRadioFrequency = "JoinLivestreamRadioFrequency"
		case leaveLiveRoom = "LeaveLiveRoom"
		case leaveLivestreamRadioFrequency = "LeaveLivestreamRadioFrequency"
		case leftLiveRoom = "LeftLiveRoom"
		case leftLivestreamRadioFrequency = "LeftLivestreamRadioFrequency"
		case notificationData = "NotificationData"
		case pollOpenClose = "PollOpenClose"
		case pollUpdateTally = "PollUpdateTally"
		case postRelease = "PostRelease"
		case radioChatter = "RadioChatter"
		case sailsConnect = "SailsConnect"
		case sailsConnected = "SailsConnected"
		case sailsDisonnect = "SailsDisonnect"
		case sailsDisonnected = "SailsDisonnected"
		case sailsHeaders = "SailsHeaders"
		case sailsStatusCode = "SailsStatusCode"
		case sendLivestreamRadioChatter = "SendLivestreamRadioChatter"
		case sentLivestreamRadioChatter = "SentLivestreamRadioChatter"
	}

	public init(chatUserList: ChatUserList?, childImageModel: ChildImageModel?, creatorMenuUpdate: CreatorMenuUpdate?, creatorNotification: CreatorNotification?, emoteList: [Emote]?, getChatUserList: GetChatUserList?, imageModel: ImageModel?, joinedLiveRoom: JoinedLiveRoom?, joinedLivestreamRadioFrequency: JoinedLivestreamRadioFrequency?, joinLiveRoom: JoinLiveRoom?, joinLivestreamRadioFrequency: JoinLivestreamRadioFrequency?, leaveLiveRoom: LeaveLiveRoom?, leaveLivestreamRadioFrequency: LeaveLivestreamRadioFrequency?, leftLiveRoom: LeftLiveRoom?, leftLivestreamRadioFrequency: LeftLivestreamRadioFrequency?, notificationData: NotificationData?, pollOpenClose: PollOpenClose?, pollUpdateTally: PollUpdateTally?, postRelease: PostRelease?, radioChatter: RadioChatter?, sailsConnect: SailsConnect?, sailsConnected: SailsConnected?, sailsDisonnect: SailsDisconnect?, sailsDisonnected: SailsDisconnected?, sailsHeaders: [String: String]?, sailsStatusCode: Int?, sendLivestreamRadioChatter: SendLivestreamRadioChatter?, sentLivestreamRadioChatter: SentLivestreamRadioChatter?) {
		self.chatUserList = chatUserList
		self.childImageModel = childImageModel
		self.creatorMenuUpdate = creatorMenuUpdate
		self.creatorNotification = creatorNotification
		self.emoteList = emoteList
		self.getChatUserList = getChatUserList
		self.imageModel = imageModel
		self.joinedLiveRoom = joinedLiveRoom
		self.joinedLivestreamRadioFrequency = joinedLivestreamRadioFrequency
		self.joinLiveRoom = joinLiveRoom
		self.joinLivestreamRadioFrequency = joinLivestreamRadioFrequency
		self.leaveLiveRoom = leaveLiveRoom
		self.leaveLivestreamRadioFrequency = leaveLivestreamRadioFrequency
		self.leftLiveRoom = leftLiveRoom
		self.leftLivestreamRadioFrequency = leftLivestreamRadioFrequency
		self.notificationData = notificationData
		self.pollOpenClose = pollOpenClose
		self.pollUpdateTally = pollUpdateTally
		self.postRelease = postRelease
		self.radioChatter = radioChatter
		self.sailsConnect = sailsConnect
		self.sailsConnected = sailsConnected
		self.sailsDisonnect = sailsDisonnect
		self.sailsDisonnected = sailsDisonnected
		self.sailsHeaders = sailsHeaders
		self.sailsStatusCode = sailsStatusCode
		self.sendLivestreamRadioChatter = sendLivestreamRadioChatter
		self.sentLivestreamRadioChatter = sentLivestreamRadioChatter
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ChatUserList

public struct ChatUserList: Codable, Hashable {
	public let body: ChatUserListBody
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: ChatUserListBody, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ChatUserListBody

public struct ChatUserListBody: Codable, Hashable {
	public let passengers, pilots: [String]
	public let success: Bool

	public init(passengers: [String], pilots: [String], success: Bool) {
		self.passengers = passengers
		self.pilots = pilots
		self.success = success
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ChildImageModel

public struct ChildImageModel: Codable, Hashable {
	public let height: Int
	public let path: String
	public let width: Int

	public init(height: Int, path: String, width: Int) {
		self.height = height
		self.path = path
		self.width = width
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Does not appear to be used in Floatplane code. This model is similar to
// ContentPostV3Response in the REST API, but without attachment details. Its purpose is to
// help dynamically insert a single post into the list of posts on the screen, instead of
// making the client re-pull the 20 latest posts.

// MARK: - CreatorMenuUpdate

public struct CreatorMenuUpdate: Codable, Hashable {
	public let data: CreatorMenuUpdateData?
	public let event: CreatorMenuUpdateEvent?

	public init(data: CreatorMenuUpdateData?, event: CreatorMenuUpdateEvent?) {
		self.data = data
		self.event = event
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - CreatorMenuUpdateData

public struct CreatorMenuUpdateData: Codable, Hashable {
	public let attachmentOrder: [String]?
	public let comments: Int?
	public let creator: String?
	public let dislikes: Int?
	public let guid, id: String?
	public let likes: Int?
	public let metadata: Metadata?
	public let releaseDate: Date?
	public let score: Int?
	public let tags: [String]?
	public let text: String?
	public let thumbnail: ImageModel?
	public let title, type: String?
	public let wasReleasedSilently: Bool?

	public init(attachmentOrder: [String]?, comments: Int?, creator: String?, dislikes: Int?, guid: String?, id: String?, likes: Int?, metadata: Metadata?, releaseDate: Date?, score: Int?, tags: [String]?, text: String?, thumbnail: ImageModel?, title: String?, type: String?, wasReleasedSilently: Bool?) {
		self.attachmentOrder = attachmentOrder
		self.comments = comments
		self.creator = creator
		self.dislikes = dislikes
		self.guid = guid
		self.id = id
		self.likes = likes
		self.metadata = metadata
		self.releaseDate = releaseDate
		self.score = score
		self.tags = tags
		self.text = text
		self.thumbnail = thumbnail
		self.title = title
		self.type = type
		self.wasReleasedSilently = wasReleasedSilently
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Metadata

public struct Metadata: Codable, Hashable {
	public let audioCount, audioDuration, galleryCount: Int?
	public let hasAudio, hasGallery, hasPicture, hasVideo: Bool?
	public let isFeatured: Bool?
	public let pictureCount, videoCount, videoDuration: Int?

	public init(audioCount: Int?, audioDuration: Int?, galleryCount: Int?, hasAudio: Bool?, hasGallery: Bool?, hasPicture: Bool?, hasVideo: Bool?, isFeatured: Bool?, pictureCount: Int?, videoCount: Int?, videoDuration: Int?) {
		self.audioCount = audioCount
		self.audioDuration = audioDuration
		self.galleryCount = galleryCount
		self.hasAudio = hasAudio
		self.hasGallery = hasGallery
		self.hasPicture = hasPicture
		self.hasVideo = hasVideo
		self.isFeatured = isFeatured
		self.pictureCount = pictureCount
		self.videoCount = videoCount
		self.videoDuration = videoDuration
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ImageModel

public struct ImageModel: Codable, Hashable {
	public let childImages: [ChildImageModel]?
	public let height: Int
	public let path: String
	public let size: Int?
	public let width: Int

	public init(childImages: [ChildImageModel]?, height: Int, path: String, size: Int?, width: Int) {
		self.childImages = childImages
		self.height = height
		self.path = path
		self.size = size
		self.width = width
	}
}

public enum CreatorMenuUpdateEvent: String, Codable, Hashable {
	case creatorMenuUpdate = "creatorMenuUpdate"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// This event is sent usually for new post notifications, where `eventType` is
// `CONTENT_POST_RELEASE`, along with information on which creator released a new post, and
// information on the post itself.

// MARK: - CreatorNotification

public struct CreatorNotification: Codable, Hashable {
	public let data: NotificationData
	public let event: CreatorNotificationEvent

	public init(data: NotificationData, event: CreatorNotificationEvent) {
		self.data = data
		self.event = event
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Contains data necessary to both show the notifiction in a user interface as well as
// technical details on what is being notified. Currently, this is used for notifying about
// new posts being released and the beginning of livestreams. Not all fields are present for
// all kinds of event types (for instance, livestream notifications do not have `video` or
// `content` objects, among others.

// MARK: - NotificationData

public struct NotificationData: Codable, Hashable {
	/// Usually the id of the blog post, when `eventType` is `CONTENT_POST_RELEASE`.
	public let content: String?
	/// The identifier of the creator the notification is from.
	public let creator: String
	/// The `CONTENT_POST_RELEASE` enumeration indicates a new post has been released. The
	/// `CONTENT_LIVESTREAM_START` enumeration indicates that a livestream has been started by
	/// the creator. Other enumerations are unknown at this time.
	public let eventType: EventType
	public let foregroundVisible: ForegroundVisible?
	public let icon: String?
	/// Usually of the format `{eventType}:{content}`.
	public let id: String
	/// Notification message/body.
	public let message: String?
	public let post: Post?
	/// If the `target.matchPortion` of the browser's current href matches the `target.match`
	/// variable via the `target.matchScheme`, and if `target.foregroundDiscardOnMatch`, then do
	/// not show this notification because the user has already seen it.
	public let target: Target?
	public let thumbnail: String?
	/// Notification title.
	public let title: String?
	public let video: Video?

	public init(content: String?, creator: String, eventType: EventType, foregroundVisible: ForegroundVisible?, icon: String?, id: String, message: String?, post: Post?, target: Target?, thumbnail: String?, title: String?, video: Video?) {
		self.content = content
		self.creator = creator
		self.eventType = eventType
		self.foregroundVisible = foregroundVisible
		self.icon = icon
		self.id = id
		self.message = message
		self.post = post
		self.target = target
		self.thumbnail = thumbnail
		self.title = title
		self.video = video
	}
}

/// The `CONTENT_POST_RELEASE` enumeration indicates a new post has been released. The
/// `CONTENT_LIVESTREAM_START` enumeration indicates that a livestream has been started by
/// the creator. Other enumerations are unknown at this time.
public enum EventType: String, Codable, Hashable {
	case contentLivestreamStart = "CONTENT_LIVESTREAM_START"
	case contentPostRelease = "CONTENT_POST_RELEASE"
}

public enum ForegroundVisible: String, Codable, Hashable {
	case no = "no"
	case yes = "yes"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Post

public struct Post: Codable, Hashable {
	public let creator, guid, id, text: String?
	public let title: String?

	public init(creator: String?, guid: String?, id: String?, text: String?, title: String?) {
		self.creator = creator
		self.guid = guid
		self.id = id
		self.text = text
		self.title = title
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// If the `target.matchPortion` of the browser's current href matches the `target.match`
// variable via the `target.matchScheme`, and if `target.foregroundDiscardOnMatch`, then do
// not show this notification because the user has already seen it.

// MARK: - Target

public struct Target: Codable, Hashable {
	public let foregroundDiscardOnMatch: Bool
	public let match: String
	/// This is usually `path` instead of `url`.
	public let matchPortion: MatchPortion
	/// This is usually `contains`.
	public let matchScheme: MatchScheme
	/// Unused in Floatplane code.
	public let url: String

	public init(foregroundDiscardOnMatch: Bool, match: String, matchPortion: MatchPortion, matchScheme: MatchScheme, url: String) {
		self.foregroundDiscardOnMatch = foregroundDiscardOnMatch
		self.match = match
		self.matchPortion = matchPortion
		self.matchScheme = matchScheme
		self.url = url
	}
}

/// This is usually `path` instead of `url`.
public enum MatchPortion: String, Codable, Hashable {
	case path = "path"
	case url = "url"
}

/// This is usually `contains`.
public enum MatchScheme: String, Codable, Hashable {
	case contains = "contains"
	case endsWith = "endsWith"
	case equals = "equals"
	case startsWith = "startsWith"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Video

public struct Video: Codable, Hashable {
	public let creator, guid: String

	public init(creator: String, guid: String) {
		self.creator = creator
		self.guid = guid
	}
}

public enum CreatorNotificationEvent: String, Codable, Hashable {
	case creatorNotification = "creatorNotification"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// When the user types this `code` in their message, surrounded by two colons (`:`), that
// portion of the message should be replaced with the `image` property in the UI.

// MARK: - Emote

public struct Emote: Codable, Hashable {
	public let code, image: String

	public init(code: String, image: String) {
		self.code = code
		self.image = image
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Returns a list of users currently in the channel/livestream/chat room, in order to
// display a full list in the UI.

// MARK: - GetChatUserList

public struct GetChatUserList: Codable, Hashable {
	public let data: GetChatUserListData
	public let headers: [String: String]
	/// This endpoint expects a GET.
	public let method: GetChatUserListMethod
	/// The required endpoint for this event.
	public let url: GetChatUserListURL

	public init(data: GetChatUserListData, headers: [String: String], method: GetChatUserListMethod, url: GetChatUserListURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - GetChatUserListData

public struct GetChatUserListData: Codable, Hashable {
	/// Which livestream channel to query. Of the format `/live/{livestreamId}`.
	public let channel: String

	public init(channel: String) {
		self.channel = channel
	}
}

public enum GetChatUserListMethod: String, Codable, Hashable {
	case methodGet = "get"
}

public enum GetChatUserListURL: String, Codable, Hashable {
	case radioMessageGetChatUserList = "/RadioMessage/getChatUserList/"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Connect to a creator's live poll room (after a socket connection has been made) in order
// to receive poll events, such as new polls, poll tally updates, and closed polls. While
// not on the chat socket, this should typically be connected to while watching a
// livestream, and disconnected when leaving a livestream.

// MARK: - JoinLiveRoom

public struct JoinLiveRoom: Codable, Hashable {
	public let data: JoinLiveRoomData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: JoinLiveRoomURL

	public init(data: JoinLiveRoomData, headers: [String: String], method: JoinLiveRoomMethod, url: JoinLiveRoomURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - JoinLiveRoomData

public struct JoinLiveRoomData: Codable, Hashable {
	/// The id of the creator for which to join the live poll room.
	public let creatorID: String

	enum CodingKeys: String, CodingKey {
		case creatorID = "creatorId"
	}

	public init(creatorID: String) {
		self.creatorID = creatorID
	}
}

public enum JoinLiveRoomMethod: String, Codable, Hashable {
	case post = "post"
}

public enum JoinLiveRoomURL: String, Codable, Hashable {
	case apiV3PollLiveJoinroom = "/api/v3/poll/live/joinroom"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Join a livestream chat channel in order to receive chat messages (via the `radioChatter`
// event) from others in the room.

// MARK: - JoinLivestreamRadioFrequency

public struct JoinLivestreamRadioFrequency: Codable, Hashable {
	public let data: JoinLivestreamRadioFrequencyData
	public let headers: [String: String]
	/// This endpoint expects a GET.
	public let method: GetChatUserListMethod
	/// The required endpoint for this event.
	public let url: JoinLivestreamRadioFrequencyURL

	public init(data: JoinLivestreamRadioFrequencyData, headers: [String: String], method: GetChatUserListMethod, url: JoinLivestreamRadioFrequencyURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - JoinLivestreamRadioFrequencyData

public struct JoinLivestreamRadioFrequencyData: Codable, Hashable {
	/// Which livestream channel to join. Of the format `/live/{livestreamId}`. The
	/// `livestreamId` comes from the `liveStream` object on the creator's info in the REST API.
	public let channel: String
	/// When joining, this is usually `null`.
	public let message: JSONNull?

	public init(channel: String, message: JSONNull?) {
		self.channel = channel
		self.message = message
	}
}

public enum JoinLivestreamRadioFrequencyURL: String, Codable, Hashable {
	case radioMessageJoinLivestreamRadioFrequency = "/RadioMessage/joinLivestreamRadioFrequency"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - JoinedLiveRoom

public struct JoinedLiveRoom: Codable, Hashable {
	public let body: JoinedLiveRoomBody
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: JoinedLiveRoomBody, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - JoinedLiveRoomBody

public struct JoinedLiveRoomBody: Codable, Hashable {
	public let activePolls: [PollOpenClose]

	public init(activePolls: [PollOpenClose]) {
		self.activePolls = activePolls
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// This schema is used for both PollOpen and PollClose.

// MARK: - PollOpenClose

public struct PollOpenClose: Codable, Hashable {
	public let poll: Poll

	public init(poll: Poll) {
		self.poll = poll
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Poll

public struct Poll: Codable, Hashable {
	/// The id of the creator that is opening the poll. Useful if multiple livestreams are
	/// happening at the same time, so the UI knows which poll to show.
	public let creator: String
	/// For PollOpen events, this is the time in which the poll should automatically close. This
	/// is usually 60 seconds after `startDate`. For PollClose events which close a poll early,
	/// this is the time in which it was closed by the creator, and is usually before the
	/// `endDate` from the corresponding PollOpen event.
	public let endDate: Date
	/// Unknown so far.
	public let finalTallyApproximate: JSONNull?
	/// Unknown so far.
	public let finalTallyReal: JSONNull?
	/// A unique identifier for the poll that is being opened or closed. Subsequent
	/// pollUpdateTally events will correspond to this id.
	public let id: String
	/// The options that the user can select in the poll.
	public let options: [String]
	public let runningTally: RunningTally
	/// When the poll was first opened.
	public let startDate: Date
	/// The main question of the poll being presented to the user.
	public let title: String
	/// The type of poll that is being shown. So far, only `simple` is known as a type here.
	public let type: String

	public init(creator: String, endDate: Date, finalTallyApproximate: JSONNull?, finalTallyReal: JSONNull?, id: String, options: [String], runningTally: RunningTally, startDate: Date, title: String, type: String) {
		self.creator = creator
		self.endDate = endDate
		self.finalTallyApproximate = finalTallyApproximate
		self.finalTallyReal = finalTallyReal
		self.id = id
		self.options = options
		self.runningTally = runningTally
		self.startDate = startDate
		self.title = title
		self.type = type
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - RunningTally

public struct RunningTally: Codable, Hashable {
	/// A list of poll vote counts for each poll option. The order of these matches the order of
	/// `options` in the initial PollOpen event. For PollOpen, these are always 0. For PollClose,
	/// these reflect the same values as the latest PollUpdateTally event.
	public let counts: [Int]
	/// A consecutively incrementing integer specifying the timeline of poll updates. Use the
	/// latest event by `tick` to show latest results. For PollOpen, this is always 0. For
	/// PollClose, this is the same tick as the latest PollUpdateTally event.
	public let tick: Int

	public init(counts: [Int], tick: Int) {
		self.counts = counts
		self.tick = tick
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Indicates that the channel has been joined successfully, as well as sending the current
// emotes configured for the livestream.

// MARK: - JoinedLivestreamRadioFrequency

public struct JoinedLivestreamRadioFrequency: Codable, Hashable {
	public let body: JoinedLivestreamRadioFrequencyBody
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: JoinedLivestreamRadioFrequencyBody, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - JoinedLivestreamRadioFrequencyBody

public struct JoinedLivestreamRadioFrequencyBody: Codable, Hashable {
	public let emotes: [Emote]?
	public let success: Bool

	public init(emotes: [Emote]?, success: Bool) {
		self.emotes = emotes
		self.success = success
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Leave a live poll room and no longer receive poll events from the creator on this socket
// connection.

// MARK: - LeaveLiveRoom

public struct LeaveLiveRoom: Codable, Hashable {
	public let data: LeaveLiveRoomData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: LeaveLiveRoomURL

	public init(data: LeaveLiveRoomData, headers: [String: String], method: JoinLiveRoomMethod, url: LeaveLiveRoomURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - LeaveLiveRoomData

public struct LeaveLiveRoomData: Codable, Hashable {
	/// The id of the creator from which to leave the live poll room.
	public let creatorID: String

	enum CodingKeys: String, CodingKey {
		case creatorID = "creatorId"
	}

	public init(creatorID: String) {
		self.creatorID = creatorID
	}
}

public enum LeaveLiveRoomURL: String, Codable, Hashable {
	case apiV3PollLiveLeaveroom = "/api/v3/poll/live/leaveroom"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Tells the server that this socket should no longer receive `radioChatter` events from the
// previously-joined channel.

// MARK: - LeaveLivestreamRadioFrequency

public struct LeaveLivestreamRadioFrequency: Codable, Hashable {
	public let data: LeaveLivestreamRadioFrequencyData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: LeaveLivestreamRadioFrequencyURL

	public init(data: LeaveLivestreamRadioFrequencyData, headers: [String: String], method: JoinLiveRoomMethod, url: LeaveLivestreamRadioFrequencyURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - LeaveLivestreamRadioFrequencyData

public struct LeaveLivestreamRadioFrequencyData: Codable, Hashable {
	/// Which livestream channel to leave. Of the format `/live/{livestreamId}`.
	public let channel: String
	/// This message does not appear to be relayed to others in the chat.
	public let message: String

	public init(channel: String, message: String) {
		self.channel = channel
		self.message = message
	}
}

public enum LeaveLivestreamRadioFrequencyURL: String, Codable, Hashable {
	case radioMessageLeaveLivestreamRadioFrequency = "/RadioMessage/leaveLivestreamRadioFrequency"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Indicates that leaving the live poll room was successful.

// MARK: - LeftLiveRoom

public struct LeftLiveRoom: Codable, Hashable {
	public let body: Bool
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: Bool, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - LeftLivestreamRadioFrequency

public struct LeftLivestreamRadioFrequency: Codable, Hashable {
	public let body, headers: [String: String]
	public let statusCode: Int

	public init(body: [String: String], headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - PollUpdateTally

public struct PollUpdateTally: Codable, Hashable {
	/// A list of poll vote counts for each poll option. The order of these matches the order of
	/// `options` in the initial PollOpen event.
	public let counts: [Int]
	/// Which poll this update corresponds to.
	public let pollID: String
	/// A consecutively incrementing integer specifying the timeline of poll updates. Use the
	/// latest event by `tick` to show latest results.
	public let tick: Int

	enum CodingKeys: String, CodingKey {
		case counts
		case pollID = "pollId"
		case tick
	}

	public init(counts: [Int], pollID: String, tick: Int) {
		self.counts = counts
		self.pollID = pollID
		self.tick = tick
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// This event is sent usually for new post notifications, where `eventType` is
// `CONTENT_POST_RELEASE`, along with information on which creator released a new post, and
// information on the post itself. This sync event type seems to be deprecated, as the
// Floatplane website uses the above `creatorNotification` instead of this `postRelease`.
// For `CONTENT_POST_RELEASE`, these two have the same schema.

// MARK: - PostRelease

public struct PostRelease: Codable, Hashable {
	public let data: NotificationData
	public let event: PostReleaseEvent

	public init(data: NotificationData, event: PostReleaseEvent) {
		self.data = data
		self.event = event
	}
}

public enum PostReleaseEvent: String, Codable, Hashable {
	case postRelease = "postRelease"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - RadioChatter

public struct RadioChatter: Codable, Hashable {
	/// Which livestream the radio chatter is from. Of the format `/live/{livestreamId}`.
	public let channel: String
	public let emotes: [Emote]?
	/// Identifier of the chat message itself. Should be unique per radio chatter.
	public let id: String
	/// Message contents. May contain emotes, a word surrounded by colons. If the emote is valid
	/// for the user, the emote code and image path are included in `emotes` below.
	public let message: String
	/// Included in `radioChatter` events and is usually `true`, but mainly useful in
	/// `SentLivestreamRadioChatter` responses to indicate if sending the message was successful.
	/// An example of why it might not work is using an invalid emote, or some system problem.
	public let success: Bool?
	/// Identifier of the user sending the message.
	public let userGUID: String
	/// Display name of the user sending the message.
	public let username: String
	public let userType: UserType

	public init(channel: String, emotes: [Emote]?, id: String, message: String, success: Bool?, userGUID: String, username: String, userType: UserType) {
		self.channel = channel
		self.emotes = emotes
		self.id = id
		self.message = message
		self.success = success
		self.userGUID = userGUID
		self.username = username
		self.userType = userType
	}
}

public enum UserType: String, Codable, Hashable {
	case moderator = "Moderator"
	case normal = "Normal"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Connect to Floatplane (after a socket connection has been made) in order to receive sync
// events, such as new post notifications.

// MARK: - SailsConnect

public struct SailsConnect: Codable, Hashable {
	/// No payload necessary.
	public let data: SailsConnectData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: SailsConnectURL

	public init(data: SailsConnectData, headers: [String: String], method: JoinLiveRoomMethod, url: SailsConnectURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// No payload necessary.

// MARK: - SailsConnectData

public struct SailsConnectData: Codable, Hashable {

	public init() {
	}
}

public enum SailsConnectURL: String, Codable, Hashable {
	case apiV3SocketConnect = "/api/v3/socket/connect"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// The response received from connecting to Floatplane for sync events. Once this is
// successfully received, sync events may appear on the socket asynchronously.

// MARK: - SailsConnected

public struct SailsConnected: Codable, Hashable {
	public let body: SailsConnectedBody
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: SailsConnectedBody, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - SailsConnectedBody

public struct SailsConnectedBody: Codable, Hashable {
	public let message: String?

	public init(message: String?) {
		self.message = message
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Disconnect from Floatplane (after a socket connection has been made) in order to stop
// receiving sync events.

// MARK: - SailsDisconnect

public struct SailsDisconnect: Codable, Hashable {
	/// No payload necessary.
	public let data: SailsDisonnectData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: SailsDisonnectURL

	public init(data: SailsDisonnectData, headers: [String: String], method: JoinLiveRoomMethod, url: SailsDisonnectURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// No payload necessary.

// MARK: - SailsDisonnectData

public struct SailsDisonnectData: Codable, Hashable {

	public init() {
	}
}

public enum SailsDisonnectURL: String, Codable, Hashable {
	case apiV3SocketDisconnect = "/api/v3/socket/disconnect"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// The response received after disconnecting from Floatplane sync events.

// MARK: - SailsDisconnected

public struct SailsDisconnected: Codable, Hashable {
	public let body: SailsDisonnectedBody
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: SailsDisonnectedBody, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - SailsDisonnectedBody

public struct SailsDisonnectedBody: Codable, Hashable {
	public let message: String?

	public init(message: String?) {
		self.message = message
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// Sends a chat message to the specified livestream channel for other users to see. Note
// that sending a chat message will both receive a Sails HTTP response as well as a
// `radioChatter` event from yourself.

// MARK: - SendLivestreamRadioChatter

public struct SendLivestreamRadioChatter: Codable, Hashable {
	public let data: SendLivestreamRadioChatterData
	public let headers: [String: String]
	/// This endpoint expects a POST.
	public let method: JoinLiveRoomMethod
	/// The required endpoint for this event.
	public let url: SendLivestreamRadioChatterURL

	public init(data: SendLivestreamRadioChatterData, headers: [String: String], method: JoinLiveRoomMethod, url: SendLivestreamRadioChatterURL) {
		self.data = data
		self.headers = headers
		self.method = method
		self.url = url
	}
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - SendLivestreamRadioChatterData

public struct SendLivestreamRadioChatterData: Codable, Hashable {
	/// Which livestream channel to send a chat to. Of the format `/live/{livestreamId}`.
	public let channel: String
	/// Message contents. May contain emotes, a word surrounded by colons. In order to send a
	/// valid emote, it should be an emote code that is returned in the
	/// `JoinedLivestreamRadioFrequency` response.
	public let message: String

	public init(channel: String, message: String) {
		self.channel = channel
		self.message = message
	}
}

public enum SendLivestreamRadioChatterURL: String, Codable, Hashable {
	case radioMessageSendLivestreamRadioChatter = "/RadioMessage/sendLivestreamRadioChatter/"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - SentLivestreamRadioChatter

public struct SentLivestreamRadioChatter: Codable, Hashable {
	public let body: RadioChatter
	public let headers: [String: String]
	public let statusCode: Int

	public init(body: RadioChatter, headers: [String: String], statusCode: Int) {
		self.body = body
		self.headers = headers
		self.statusCode = statusCode
	}
}

// MARK: - Encode/decode helpers

public class JSONNull: Codable, Hashable {

	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
		return true
	}

	public var hashValue: Int {
		return 0
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}
