import Foundation
import Vapor
import FloatplaneAPIClient

protocol FPAPIService {
	// Auth-related
	func getUserSelf() -> EventLoopFuture<UserV3API.GetSelf>
	func listUserSubscriptionsV3() -> EventLoopFuture<SubscriptionsV3API.ListUserSubscriptionsV3>
	func getInfo(creatorGUID: [String]) -> EventLoopFuture<CreatorV2API.GetInfo>
	func getUsers(ids: [String]) -> EventLoopFuture<UserV2API.GetUserInfo>
	func login(username: String, password: String, captchaToken: String?) -> EventLoopFuture<AuthV2API.Login>
	func secondFactor(token: String) -> EventLoopFuture<AuthV2API.CheckFor2faLogin>
	
	// Creator-related
	func getHomeContent(ids: [String], limit: Int, lastItems: [ContentCreatorListLastItems]?) -> EventLoopFuture<ContentV3API.GetMultiCreatorBlogPosts>
	func getCreatorContent(id: String, limit: Int, fetchAfter: Int?, search: String?) -> EventLoopFuture<ContentV3API.GetCreatorBlogPosts>
	func getLivestream(url: URI) -> EventLoopFuture<ClientResponse>
	
	// Post-related
	func getBlogPost(id: String) -> EventLoopFuture<ContentV3API.GetBlogPost>
	func getVideoContent(id: String) -> EventLoopFuture<ContentV3API.GetVideoContent>
	func getCdn(type: CDNV2API.ModelType_getDeliveryInfo, id: String) -> EventLoopFuture<CDNV2API.GetDeliveryInfo>
	func getPictureContent(id: String) -> EventLoopFuture<ContentV3API.GetPictureContent>
	
	// Interaction-related
	func likeContent(id: String) -> EventLoopFuture<ContentV3API.LikeContent>
	func dislikeContent(id: String) -> EventLoopFuture<ContentV3API.DislikeContent>
}

class DefaultFPAPIService: FPAPIService {
	func getUserSelf() -> EventLoopFuture<UserV3API.GetSelf> {
		return UserV3API.getSelf()
	}
	func listUserSubscriptionsV3() -> EventLoopFuture<SubscriptionsV3API.ListUserSubscriptionsV3> {
		return SubscriptionsV3API.listUserSubscriptionsV3()
	}
	func getInfo(creatorGUID: [String]) -> EventLoopFuture<CreatorV2API.GetInfo> {
		return CreatorV2API.getInfo(creatorGUID: creatorGUID)
	}
	func getUsers(ids: [String]) -> EventLoopFuture<UserV2API.GetUserInfo> {
		return UserV2API.getUserInfo(id: ids)
	}
	func login(username: String, password: String, captchaToken: String?) -> EventLoopFuture<AuthV2API.Login> {
		return AuthV2API.login(authLoginV2Request: .init(username: username, password: password, captchaToken: captchaToken))
	}
	func secondFactor(token: String) -> EventLoopFuture<AuthV2API.CheckFor2faLogin> {
		return AuthV2API.checkFor2faLogin(checkFor2faLoginRequest: .init(token: token))
	}
	func getHomeContent(ids: [String], limit: Int, lastItems: [ContentCreatorListLastItems]?) -> EventLoopFuture<ContentV3API.GetMultiCreatorBlogPosts> {
		return ContentV3API.getMultiCreatorBlogPosts(ids: ids, limit: limit, fetchAfter: lastItems)
	}
	func getCreatorContent(id: String, limit: Int, fetchAfter: Int? = nil, search: String? = nil) -> EventLoopFuture<ContentV3API.GetCreatorBlogPosts> {
		return ContentV3API.getCreatorBlogPosts(id: id, limit: limit, fetchAfter: fetchAfter, search: search)
	}
	func getLivestream(url: URI) -> EventLoopFuture<ClientResponse> {
		return Configuration.apiClient!.get(url)
	}
	func getBlogPost(id: String) -> EventLoopFuture<ContentV3API.GetBlogPost> {
		return ContentV3API.getBlogPost(id: id)
	}
	func getVideoContent(id: String) -> EventLoopFuture<ContentV3API.GetVideoContent> {
		return ContentV3API.getVideoContent(id: id)
	}
	func getCdn(type: CDNV2API.ModelType_getDeliveryInfo, id: String) -> EventLoopFuture<CDNV2API.GetDeliveryInfo> {
		switch type {
		case .live:
			return CDNV2API.getDeliveryInfo(type: type, creator: id)
		default:
			return CDNV2API.getDeliveryInfo(type: type, guid: id)
		}
	}
	func getPictureContent(id: String) -> EventLoopFuture<ContentV3API.GetPictureContent> {
		return ContentV3API.getPictureContent(id: id)
	}
	func likeContent(id: String) -> EventLoopFuture<ContentV3API.LikeContent> {
		return ContentV3API.likeContent(contentLikeV3Request: .init(contentType: .blogpost, id: id))
	}
	func dislikeContent(id: String) -> EventLoopFuture<ContentV3API.DislikeContent> {
		return ContentV3API.dislikeContent(contentLikeV3Request: .init(contentType: .blogpost, id: id))
	}
}

class MockFPAPIService: FPAPIService {
	private var eventLoop: EventLoop {
		Configuration.apiClient!.eventLoop
	}
	
	func getUserSelf() -> EventLoopFuture<UserV3API.GetSelf> {
		return eventLoop.makeSucceededFuture(.http401(value: ErrorModel(id: "", errors: [], message: ""), raw: ClientResponse()))
//		return eventLoop.makeSucceededFuture(.http200(value: MockData.userSelf, raw: ClientResponse()))
	}
	func listUserSubscriptionsV3() -> EventLoopFuture<SubscriptionsV3API.ListUserSubscriptionsV3> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.userSubscriptions, raw: ClientResponse()))
	}
	func getInfo(creatorGUID: [String]) -> EventLoopFuture<CreatorV2API.GetInfo> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.creators, raw: ClientResponse()))
	}
	func getUsers(ids: [String]) -> EventLoopFuture<UserV2API.GetUserInfo> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.creatorOwners, raw: ClientResponse()))
	}
	func login(username: String, password: String, captchaToken: String?) -> EventLoopFuture<AuthV2API.Login> {
		return eventLoop.makeSucceededFuture(.http200(value: .init(user: nil, needs2FA: true), raw: ClientResponse()))
	}
	func secondFactor(token: String) -> EventLoopFuture<AuthV2API.CheckFor2faLogin> {
		return eventLoop.makeSucceededFuture(.http200(value: .init(user: .init(id: "1", username: "my_username", profileImage: .init(width: 1, height: 1, path: "", size: nil, childImages: nil)), needs2FA: false), raw: ClientResponse()))
	}
	func getHomeContent(ids: [String], limit: Int, lastItems: [ContentCreatorListLastItems]?) -> EventLoopFuture<ContentV3API.GetMultiCreatorBlogPosts> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.blogPosts, raw: ClientResponse()))
	}
	func getCreatorContent(id: String, limit: Int, fetchAfter: Int? = nil, search: String? = nil) -> EventLoopFuture<ContentV3API.GetCreatorBlogPosts> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.blogPosts.blogPosts, raw: ClientResponse()))
	}
	func getLivestream(url: URI) -> EventLoopFuture<ClientResponse> {
		return eventLoop.makeSucceededFuture(ClientResponse(status: .notFound, headers: .init(), body: nil))
	}
	func getBlogPost(id: String) -> EventLoopFuture<ContentV3API.GetBlogPost> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.getBlogPost, raw: ClientResponse()))
	}
	func getVideoContent(id: String) -> EventLoopFuture<ContentV3API.GetVideoContent> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.getVideoContent, raw: ClientResponse()))
	}
	func getCdn(type: CDNV2API.ModelType_getDeliveryInfo, id: String) -> EventLoopFuture<CDNV2API.GetDeliveryInfo> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.getCdn, raw: ClientResponse()))
	}
	func getPictureContent(id: String) -> EventLoopFuture<ContentV3API.GetPictureContent> {
		return eventLoop.makeSucceededFuture(.http200(value: MockData.getPictureContent, raw: ClientResponse()))
	}
	func likeContent(id: String) -> EventLoopFuture<ContentV3API.LikeContent> {
		return eventLoop.makeSucceededFuture(.http200(value: ["like"], raw: ClientResponse()))
	}
	func dislikeContent(id: String) -> EventLoopFuture<ContentV3API.DislikeContent> {
		return eventLoop.makeSucceededFuture(.http200(value: ["dislike"], raw: ClientResponse()))
	}
}

enum MockData {
	static let decoder = try! Configuration.contentConfiguration.requireDecoder(for: .json)
	
	static let userSelf: UserSelfV3Response = {
		return try! decoder.decode(UserSelfV3Response.self, from: ByteBuffer(string: MockStaticData.userSelf), headers: .init())
	}()
	
	static let userSubscriptions: [UserSubscriptionModel] = {
		return try! decoder.decode([UserSubscriptionModel].self, from: ByteBuffer(string: MockStaticData.userSubscriptions), headers: .init())
	}()
	
	static let creators: [CreatorModelV2] = {
		return try! decoder.decode([CreatorModelV2].self, from: ByteBuffer(string: MockStaticData.creators), headers: .init())
	}()
	
	static let creatorOwners: UserInfoV2Response = {
		return try! decoder.decode(UserInfoV2Response.self, from: ByteBuffer(string: MockStaticData.creatorOwners), headers: .init())
	}()
	
	static let userInfo: UserInfo = {
		let a = UserInfo()
		a.userSelf = userSelf
		a.userSubscriptions = userSubscriptions
		a.creators = Dictionary(uniqueKeysWithValues: creators.map({ ($0.id, $0) }))
		a.creatorOwners = Dictionary(uniqueKeysWithValues: creatorOwners.users.map({ ($0.user.id, $0.user) }))
		return a
	}()
	
	static let blogPosts: ContentCreatorListV3Response = {
		let blogPosts = try! decoder.decode(ContentCreatorListV3Response.self, from: ByteBuffer(string: MockStaticData.getHomeContent), headers: .init())
		return blogPosts
	}()
	
	static let getBlogPost: ContentPostV3Response = {
		return try! decoder.decode(ContentPostV3Response.self, from: ByteBuffer(string: MockStaticData.getBlogPost), headers: .init())
	}()
	
	static let getVideoContent: ContentVideoV3Response = {
		return try! decoder.decode(ContentVideoV3Response.self, from: ByteBuffer(string: MockStaticData.getVideoContent), headers: .init())
	}()
	
	static let getCdn: CdnDeliveryV2Response = {
		return try! decoder.decode(CdnDeliveryV2Response.self, from: ByteBuffer(string: MockStaticData.getCdn), headers: .init())
	}()
	
	static let getPictureContent: ContentPictureV3Response = {
		return try! decoder.decode(ContentPictureV3Response.self, from: ByteBuffer(string: MockStaticData.getPictureContent), headers: .init())
	}()
}
	
enum MockStaticData {
	static let userSelf: String = #"""
{
	"id": "0123456789abcdef01234567",
	"username": "my_username",
	"profileImage": {
		"width": 512,
		"height": 512,
		"path": "https://pbs.floatplane.com/profile_images/default/user12.png",
		"childImages": [
			{
				"width": 250,
				"height": 250,
				"path": "https://pbs.floatplane.com/profile_images/default/user12_250x250.png"
			},
			{
				"width": 100,
				"height": 100,
				"path": "https://pbs.floatplane.com/profile_images/default/user12_100x100.png"
			}
		]
	},
	"email": "testemail@example.com",
	"displayName": "Firstname Lastname",
	"creators": [],
	"scheduledDeletionDate": null
}
"""#
	static let userSubscriptions: String = #"""
[
	{
		"startDate": "2020-09-25T07:35:04.273Z",
		"endDate": "2021-09-25T07:35:04.273Z",
		"paymentID": 12345,
		"interval": "year",
		"paymentCancelled": false,
		"plan": {
			"id": "5d48d0306825b5780db93d07",
			"title": "LTT Supporter (1080p)",
			"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
			"price": "5.00",
			"priceYearly": "50.00",
			"currency": "usd",
			"logo": null,
			"interval": "month",
			"featured": true,
			"allowGrandfatheredAccess": false,
			"discordServers": [],
			"discordRoles": []
		},
		"creator": "59f94c0bdd241b70349eb72b"
	}
]
"""#
	static let creators: String = #"""
[
	{
		"id": "59f94c0bdd241b70349eb72b",
		"owner": "59f94c0bdd241b70349eb723",
		"title": "LinusTechTips",
		"urlname": "linustechtips",
		"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
		"about": "# We're LinusTechTips\nWe make *videos* and stuff, cool eh?",
		"category": "59f94c0bdd241b70349eb727",
		"cover": {
			"width": 1990,
			"height": 519,
			"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
			"childImages": [
				{
					"width": 1245,
					"height": 325,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
				}
			]
		},
		"icon": {
			"width": 600,
			"height": 600,
			"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
			"childImages": [
				{
					"width": 250,
					"height": 250,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
				},
				{
					"width": 100,
					"height": 100,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
				}
			]
		},
		"liveStream": {
			"id": "5c13f3c006f1be15e08e05c0",
			"title": "We're Changing Our Name - WAN Show October 29, 2021",
			"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
					}
				]
			},
			"owner": "59f94c0bdd241b70349eb72b",
			"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
			"offline": {
				"title": "Offline",
				"description": "We're offline for now – please check back later!",
				"thumbnail": {
					"width": 1920,
					"height": 1080,
					"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
					"childImages": [
						{
							"width": 400,
							"height": 225,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
						},
						{
							"width": 1200,
							"height": 675,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
						}
					]
				}
			}
		},
		"subscriptionPlans": null,
		"discoverable": true,
		"subscriberCountDisplay": "total",
		"incomeDisplay": false,
		"socialLinks": {
			"instagram": "https://www.instagram.com/linustech/",
			"website": "https://linustechtips.com",
			"facebook": "https://www.facebook.com/LinusTech",
			"youtube": "https://www.youtube.com/user/LinusTechTips",
			"twitter": "https://twitter.com/linustech"
		},
		"discordServers": [
			{
				"id": "5baa8838d9f3aa0a83acd429",
				"guildName": "LinusTechTips",
				"guildIcon": "a_528743a32b33b5eb227a8405d5593473",
				"inviteLink": "https://discord.gg/LTT",
				"inviteMode": "link"
			},
			{
				"id": "5e34cd9a9dbb744872192895",
				"guildName": "LTT Minecraft Network",
				"guildIcon": "4f7f812b49196b1646bdcdb84b948c84",
				"inviteLink": "https://discord.gg/VVpwBPXrMc",
				"inviteMode": "link"
			}
		]
	}
]
"""#
	static let creatorOwners: String = #"""
{
	"users": [
		{
			"id": "59f94c0bdd241b70349eb723",
			"user": {
				"id": "59f94c0bdd241b70349eb723",
				"username": "Linus",
				"profileImage": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/profile_images/59f94c0bdd241b70349eb723/013264939123424_1535577174346.jpeg",
					"childImages": [
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/profile_images/59f94c0bdd241b70349eb723/013264939123424_1535577174346_100x100.jpeg"
						},
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/profile_images/59f94c0bdd241b70349eb723/013264939123424_1535577174346_250x250.jpeg"
						}
					]
				}
			}
		}
	]
}
"""#
	static let getHomeContent: String = #"""
{
	"blogPosts": [
		{
			"id": "0YXGhFR08U",
			"guid": "0YXGhFR08U",
			"title": "I Bought an Alderlake Engineering Sample on Chinese Craigslist",
			"text": "<p>Linus tries to get Intel 12th Gen early by buying an Engineering Sample CPU off China's version of Craigslist....But will the motherboards play nice?</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"7Wgsd59qiX"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 556,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-04T02:33:00.029Z",
			"likes": 86,
			"dislikes": 2,
			"score": 84,
			"comments": 32,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/0YXGhFR08U/977437854685493_1635990437631.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/0YXGhFR08U/977437854685493_1635990437631_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/0YXGhFR08U/977437854685493_1635990437631_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"7Wgsd59qiX"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "FYfn7g1ohU",
			"guid": "FYfn7g1ohU",
			"title": "TL: Facebook fights Apple, stops Facial Recognition + more!",
			"text": "<p><strong>NEWS SOURCES:</strong></p><p><strong> </strong></p><p>FACE-OFF</p><p>FB lets creators skip Apple Tax</p><p><a href=\"https://www.engadget.com/facebook-has-a-new-plan-to-help-creators-avoid-app-store-fees-174337629.html\">https://www.engadget.com/facebook-has-a-new-plan-to-help-creators-avoid-app-store-fees-174337629.html</a></p><p><a href=\"https://www.facebook.com/zuck/posts/10114044739955341\">https://www.facebook.com/zuck/posts/10114044739955341</a> </p><p>Sideloading ‘is a cyber criminal’s best friend’ <a href=\"https://www.theverge.com/2021/11/3/22761724/apple-craig-federighi-ios-sideloading-web-summit-2021-european-commission-digital-markets-act\">https://www.theverge.com/2021/11/3/22761724/apple-craig-federighi-ios-sideloading-web-summit-2021-european-commission-digital-markets-act</a></p><p><a href=\"https://www.cnbc.com/2021/11/03/apple-exec-european-app-store-regulation-would-open-pandoras-box.html\">https://www.cnbc.com/2021/11/03/apple-exec-european-app-store-regulation-would-open-pandoras-box.html</a> </p><p> </p><p>PUTTING ON A NEW FACEBOOK</p><p>Facebook ends facial recognition</p><p><a href=\"https://linustechtips.com/topic/1385742-facebook-shutting-down-its-face-recognition-system/\">https://linustechtips.com/topic/1385742-facebook-shutting-down-its-face-recognition-system/</a> </p><p><a href=\"https://techcrunch.com/2021/11/02/facebook-face-recognition-data-deleting/\">https://techcrunch.com/2021/11/02/facebook-face-recognition-data-deleting/</a> </p><p>Clearview AI has to delete Australia <a href=\"https://www.theguardian.com/world/2021/nov/03/facial-recognition-firm-cleaview-ai-to-appeal-order-to-stop-collecting-images-of-australians\">https://www.theguardian.com/world/2021/nov/03/facial-recognition-firm-cleaview-ai-to-appeal-order-to-stop-collecting-images-of-australians</a> </p><p>Don’t celebrate yet <a href=\"https://www.vox.com/recode/22761598/facebook-facial-recognition-meta\">https://www.vox.com/recode/22761598/facebook-facial-recognition-meta</a></p><p><a href=\"https://about.fb.com/news/2021/11/update-on-use-of-face-recognition/\">https://about.fb.com/news/2021/11/update-on-use-of-face-recognition/</a> </p><p>also Facebook, Instagram outage again</p><p><a href=\"https://twitter.com/messenger/status/1455982683096379400\">https://twitter.com/messenger/status/1455982683096379400</a> </p><p> </p><p>SECURITY HOLES, I CANNOT A-BIDE</p><p>Biden admin mandates cybersecurity overhaul</p><p><a href=\"https://www.theverge.com/2021/11/3/22761208/biden-administration-security-vulnerabilities-patch\">https://www.theverge.com/2021/11/3/22761208/biden-administration-security-vulnerabilities-patch</a> </p><p><a href=\"https://www.cisa.gov/news/2021/11/03/cisa-releases-directive-reducing-significant-risk-known-exploited-vulnerabilities\">https://www.cisa.gov/news/2021/11/03/cisa-releases-directive-reducing-significant-risk-known-exploited-vulnerabilities</a> </p><p><a href=\"https://www.wsj.com/articles/biden-administration-to-order-federal-agencies-to-fix-hundreds-of-cyber-flaws-11635937200\">https://www.wsj.com/articles/biden-administration-to-order-federal-agencies-to-fix-hundreds-of-cyber-flaws-11635937200</a> </p><p><a href=\"https://cyber.dhs.gov/bod/22-01/\">https://cyber.dhs.gov/bod/22-01/</a></p><p><br /></p><p> QUICK BITS</p><p> </p><p>NO KIDNAPPING PEACH THIS TIME</p><p>Gary Bowser pleads guilty</p><p><a href=\"https://www.eurogamer.net/articles/2021-04-17-nintendo-suing-switch-hacker-gary-bowser\">https://www.eurogamer.net/articles/2021-04-17-nintendo-suing-switch-hacker-gary-bowser</a></p><p><a href=\"https://arstechnica.com/gaming/2021/11/hacker-will-pay-nintendo-4-5-million-in-team-xecuter-plea-bargain\">https://arstechnica.com/gaming/2021/11/hacker-will-pay-nintendo-4-5-million-in-team-xecuter-plea-bargain</a></p><p><a href=\"https://kotaku.com/gary-bowser-pleads-guilty-to-piracy-charges-after-ninte-1847978204\">https://kotaku.com/gary-bowser-pleads-guilty-to-piracy-charges-after-ninte-1847978204</a> </p><p><a href=\"https://torrentfreak.com/team-xecuters-gary-bowser-pleads-guilty-to-criminal-charges-211101/\">https://torrentfreak.com/team-xecuters-gary-bowser-pleads-guilty-to-criminal-charges-211101/</a></p><p> </p><p>SOFTWARE DEVELOPMENT ISN’T E.V.</p><p>Tesla recalls 12,000 vehicles to fix the firmware</p><p><a href=\"https://www.cnet.com/roadshow/news/tesla-recalls-12000-evs-affected-by-full-self-driving-beta-issues/\">https://www.cnet.com/roadshow/news/tesla-recalls-12000-evs-affected-by-full-self-driving-beta-issues/</a> </p><p><a href=\"https://apnews.com/article/technology-business-software-d3e2107435f432fd9b36ba14898166a0\">https://apnews.com/article/technology-business-software-d3e2107435f432fd9b36ba14898166a0</a> </p><p>2nd recall in weeks: <a href=\"https://www.engadget.com/tesla-recall-suspension-model-y-3-191031712.html\">https://www.engadget.com/tesla-recall-suspension-model-y-3-191031712.html</a></p><p> </p><p>THE (VERY LIMITED) METAVERSE</p><p>Apple VR/AR headset in 2022?</p><p><a href=\"https://www.macrumors.com/2021/11/01/apple-ar-vr-headset-wifi-6e-support/\">https://www.macrumors.com/2021/11/01/apple-ar-vr-headset-wifi-6e-support/</a> </p><p><a href=\"https://appleinsider.com/articles/21/11/01/apple-headset-will-have-wi-fi-6-production-to-begin-q4-2022\">https://appleinsider.com/articles/21/11/01/apple-headset-will-have-wi-fi-6-production-to-begin-q4-2022</a></p><p> </p><p>A GAMES SMORGASBORD</p><p>Netflix Android games roll out globally</p><p><a href=\"https://www.reuters.com/technology/netflix-rolls-out-mobile-games-subscribers-android-2021-11-02/\">https://www.reuters.com/technology/netflix-rolls-out-mobile-games-subscribers-android-2021-11-02/</a> </p><p><a href=\"https://twitter.com/NetflixGeeked/status/1455580571959054341\">https://twitter.com/NetflixGeeked/status/1455580571959054341</a> </p><p><a href=\"https://play.google.com/store/apps/developer?id=Netflix,+Inc\">https://play.google.com/store/apps/developer?id=Netflix,+Inc</a>. </p><p> </p><p>COULD’VE SKIPPED THE INK</p><p>Squid Game crypto was a scam, uh… surprise</p><p><a href=\"https://linustechtips.com/topic/1385598-just-another-cryptoscam/\">https://linustechtips.com/topic/1385598-just-another-cryptoscam/</a> </p><p><a href=\"https://mashable.com/article/squid-game-cryptocurrency-scam\">https://mashable.com/article/squid-game-cryptocurrency-scam</a> </p><p> </p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"3rvNHmfbhl"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 325,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-04T00:57:00.033Z",
			"likes": 54,
			"dislikes": 1,
			"score": 53,
			"comments": 2,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/FYfn7g1ohU/588755385959414_1635987379742.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/FYfn7g1ohU/588755385959414_1635987379742_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/FYfn7g1ohU/588755385959414_1635987379742_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"3rvNHmfbhl"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "rynZkRI9Mv",
			"guid": "rynZkRI9Mv",
			"title": "SC: Beats Fit Pro",
			"text": "<p>Buy Beats Fit Pro</p><p>On Best Buy (Paid Link): <a href=\"https://geni.us/kcSC\">https://geni.us/kcSC</a></p><p>On BHPhoto (Paid Link): <a href=\"https://geni.us/iRUF\">https://geni.us/iRUF</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"BviZsThLCL"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 815,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-04T00:52:00.018Z",
			"likes": 37,
			"dislikes": 0,
			"score": 37,
			"comments": 8,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/rynZkRI9Mv/029309153423840_1635984321423.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/rynZkRI9Mv/029309153423840_1635984321423_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/rynZkRI9Mv/029309153423840_1635984321423_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"BviZsThLCL"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "iJRU7mKzDM",
			"guid": "iJRU7mKzDM",
			"title": "FP Excusive: What really is the BEST pizza topping?!",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"9w4G9vOxw4"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 115,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-04T00:47:00.035Z",
			"likes": 105,
			"dislikes": 1,
			"score": 104,
			"comments": 78,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/iJRU7mKzDM/891014925262791_1635986185824.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/iJRU7mKzDM/891014925262791_1635986185824_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/iJRU7mKzDM/891014925262791_1635986185824_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"9w4G9vOxw4"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "oyAQHtVaOj",
			"guid": "oyAQHtVaOj",
			"title": "TJM: Last Night in Soho",
			"text": "<p>The latest film from English auteur Edgar Wright, Last Night in Soho stars Thomasin McKenzie (from Jojo Rabbit) and Anya Taylor-Joy (of Queen's Gambit fame) in a genre-blending roller coaster with a lot to say!</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"PPkI9eB2en",
				"aMs57Ucwmx"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 4454,
				"hasAudio": true,
				"audioCount": 1,
				"audioDuration": 4448,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-03T18:22:00.048Z",
			"likes": 13,
			"dislikes": 1,
			"score": 12,
			"comments": 8,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/oyAQHtVaOj/837081105999654_1635956944008.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/oyAQHtVaOj/837081105999654_1635956944008_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/oyAQHtVaOj/837081105999654_1635956944008_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"PPkI9eB2en"
			],
			"audioAttachments": [
				"aMs57Ucwmx"
			],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "hx2xDjwZW7",
			"guid": "hx2xDjwZW7",
			"title": "SC: Sony Xperia Pro-I",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"K7VUYMB54R"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 823,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-02T19:36:00.031Z",
			"likes": 276,
			"dislikes": 2,
			"score": 274,
			"comments": 73,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/hx2xDjwZW7/068070201432017_1635879391852.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/hx2xDjwZW7/068070201432017_1635879391852_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/hx2xDjwZW7/068070201432017_1635879391852_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"K7VUYMB54R"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "tWirNfoeg9",
			"guid": "tWirNfoeg9",
			"title": "TQ: Apple MagSafe Is Back - What To Know",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"YEmSGec0mR"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 215,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-02T17:04:00.031Z",
			"likes": 170,
			"dislikes": 2,
			"score": 168,
			"comments": 28,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/tWirNfoeg9/927349533770584_1635871282040.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/tWirNfoeg9/927349533770584_1635871282040_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/tWirNfoeg9/927349533770584_1635871282040_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"YEmSGec0mR"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "oHGdwpStGV",
			"guid": "oHGdwpStGV",
			"title": "BLOAT is killing your FPS",
			"text": "<p>Is your PC not like it used to be? Games, apps, and BLOAT could be robbing you of performance, so we’re gonna figure out just how much overhead is used to run all those background apps. </p><p><br /></p><p><a href=\"https://winaero.com/winaero-tweaker/\">https://winaero.com/winaero-tweaker/</a></p><p><br /></p><p>Thanks to Seasonic for sponsoring this video! </p><p>Buy Seasonic Prime TX-1000 PSU</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/zCAg\">https://geni.us/zCAg</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/jOhH3v\">https://geni.us/jOhH3v</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/DtKK5Sb\">https://geni.us/DtKK5Sb</a></p><p><br /></p><p>Is your PC not like it used to be? Games, apps, and BLOAT could be robbing you of performance, so we’re gonna figure out just how much overhead is used to run all those background apps. </p><p><br /></p><p>Buy MSI MPG Z590 Gaming Plus</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/BBPsER1\">https://geni.us/BBPsER1</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/uSx0B\">https://geni.us/uSx0B</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/KWkgPIj\">https://geni.us/KWkgPIj</a></p><p><br /></p><p>Buy Intel Core i7-11700K</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/RhXe8Mw\">https://geni.us/RhXe8Mw</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/WItHY6\">https://geni.us/WItHY6</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/snZ4E\">https://geni.us/snZ4E</a></p><p><br /></p><p>Buy Crucial P5 Plus 1TB NVMe SSD</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/snZ4E\">https://geni.us/snZ4E</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/2ILUr\">https://geni.us/2ILUr</a></p><p>On B&amp;H (PAID LINK): <a href=\"https://geni.us/gdNb2os\">https://geni.us/gdNb2os</a></p><p><br /></p><p>Buy G.Skill Trident Z NEO Series 16GB (2 x 8GB) DDR4 RAM</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/S84oloK\">https://geni.us/S84oloK</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/BRfsjUq\">https://geni.us/BRfsjUq</a></p><p><br /></p><p>Buy MSI Gaming X Trio RTX 3080</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/bjQw\">https://geni.us/bjQw</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/BKo8lsD\">https://geni.us/BKo8lsD</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/p6Byn\">https://geni.us/p6Byn</a></p><p><br /></p><p>Buy Noctua NH-U12S</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/beHeQ\">https://geni.us/beHeQ</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/PVAA9\">https://geni.us/PVAA9</a></p><p>On B&amp;H (PAID LINK): <a href=\"https://geni.us/ZAA3M\">https://geni.us/ZAA3M</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"pJUi20pMKA"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 693,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-02T16:49:00.031Z",
			"likes": 237,
			"dislikes": 14,
			"score": 223,
			"comments": 70,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/oHGdwpStGV/808938546471519_1635787266584.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/oHGdwpStGV/808938546471519_1635787266584_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/oHGdwpStGV/808938546471519_1635787266584_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"pJUi20pMKA"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "S5QkoDbsuk",
			"guid": "S5QkoDbsuk",
			"title": "TL: Windows 11 Ryzen issue, Roblox outage, Tesla shares chargers + more!",
			"text": "<p><strong>NEWS SOURCES:</strong></p><p> </p><p>WELL…THAT SUCKS</p><p><a href=\"https://www.techpowerup.com/287786/first-windows-11-patch-tuesday-makes-ryzen-l3-cache-latency-worse-amd-puts-out-fix-dates\">https://www.techpowerup.com/287786/first-windows-11-patch-tuesday-makes-ryzen-l3-cache-latency-worse-amd-puts-out-fix-dates</a></p><p><a href=\"https://www.pcworld.com/article/546316/windows-11-update-fixes-ryzen-l3-perf-bug.html\">https://www.pcworld.com/article/546316/windows-11-update-fixes-ryzen-l3-perf-bug.html</a></p><p><a href=\"https://twitter.com/HardwareUnboxed/status/1454778534929461249\">https://twitter.com/HardwareUnboxed/status/1454778534929461249</a></p><p><a href=\"https://twitter.com/PowerGPU/status/1454820940907532294\">https://twitter.com/PowerGPU/status/1454820940907532294</a></p><p> </p><p>TURNS OUT IT WASN’T A BAD BURRITO</p><p><a href=\"https://www.cnbc.com/2021/11/01/gaming-platform-roblox-comes-back-online-after-three-day-outage.html\">https://www.cnbc.com/2021/11/01/gaming-platform-roblox-comes-back-online-after-three-day-outage.html</a></p><p><a href=\"https://www.marketwatch.com/story/roblox-sheds-more-than-1-billion-in-market-cap-after-outage-that-could-have-cost-millions-11635792411\">https://www.marketwatch.com/story/roblox-sheds-more-than-1-billion-in-market-cap-after-outage-that-could-have-cost-millions-11635792411</a></p><p><a href=\"https://www.bbc.com/news/technology-59120085\">https://www.bbc.com/news/technology-59120085</a></p><p><br /></p><p>A SUPERCHARGER THAT’S ACTUALLY SUPER</p><p><a href=\"https://electrek.co/2021/11/01/tesla-launches-pilot-program-for-non-tesla-evs-open-supercharger-network/\">https://electrek.co/2021/11/01/tesla-launches-pilot-program-for-non-tesla-evs-open-supercharger-network/</a></p><p><a href=\"https://techcrunch.com/2021/11/01/tesla-is-opening-its-supercharger-network-to-other-evs-for-the-first-time/\">https://techcrunch.com/2021/11/01/tesla-is-opening-its-supercharger-network-to-other-evs-for-the-first-time/</a></p><p><a href=\"https://www.investors.com/news/tesla-stock-pops-opens-supercharger-network-other-evs-europe/\">https://www.investors.com/news/tesla-stock-pops-opens-supercharger-network-other-evs-europe/</a></p><p> </p><p>QUICK BITS</p><p> </p><p>NOT THAT KIND OF IPHONE CRASH</p><p><a href=\"https://www.engadget.com/apples-i-phone-could-soon-detect-a-car-crash-and-dial-911-automatically-134124164.html\">https://www.engadget.com/apples-i-phone-could-soon-detect-a-car-crash-and-dial-911-automatically-134124164.html</a></p><p><a href=\"https://www.cnet.com/roadshow/news/apple-iphone-car-crash-automatic-911/\">https://www.cnet.com/roadshow/news/apple-iphone-car-crash-automatic-911/</a></p><p><a href=\"https://www.macrumors.com/2021/11/01/apple-car-crash-detection-feature-report/\">https://www.macrumors.com/2021/11/01/apple-car-crash-detection-feature-report/</a></p><p> </p><p>CASELABS: BACK FROM THE DEAD</p><p><a href=\"https://www.gamersnexus.net/news-pc/3669-hw-news-caselabs-back-from-dead-linux-gaming-valve-steam-deck\">https://www.gamersnexus.net/news-pc/3669-hw-news-caselabs-back-from-dead-linux-gaming-valve-steam-deck</a></p><p><a href=\"https://www.kitguru.net/components/cases/joao-silva/caselabs-is-making-a-comeback-thanks-to-a-new-owner/\">https://www.kitguru.net/components/cases/joao-silva/caselabs-is-making-a-comeback-thanks-to-a-new-owner/</a></p><p> </p><p>FAREWELL HEXUS!</p><p><a href=\"https://hexus.net/tech/news/industry/148580-cheer-up-its-end-world/\">https://hexus.net/tech/news/industry/148580-cheer-up-its-end-world/</a></p><p><a href=\"https://bit-tech.net/news/the-end/1/\">https://bit-tech.net/news/the-end/1/</a></p><p> </p><p>CHASING DOWN ELON</p><p><a href=\"https://spacenews.com/abl-space-systems-to-launch-project-kuipers-first-satellites-in-2022/\">https://spacenews.com/abl-space-systems-to-launch-project-kuipers-first-satellites-in-2022/</a></p><p><a href=\"https://seekingalpha.com/news/3761722-amazon-says-first-project-kuiper-internet-satellites-to-launch-in-late-2022\">https://seekingalpha.com/news/3761722-amazon-says-first-project-kuiper-internet-satellites-to-launch-in-late-2022</a></p><p> </p><p>FILL IT WITH MEMES</p><p><a href=\"https://www.tomshardware.com/news/5d-storage-optical-data-cube\">https://www.tomshardware.com/news/5d-storage-optical-data-cube</a></p><p><a href=\"https://hothardware.com/news/5d-storage-can-stuff-500tb-on-glass-disc\">https://hothardware.com/news/5d-storage-can-stuff-500tb-on-glass-disc</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"hAicM0Qams"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 324,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-02T01:00:00.033Z",
			"likes": 178,
			"dislikes": 0,
			"score": 178,
			"comments": 45,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/S5QkoDbsuk/005115268792275_1635814787236.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/S5QkoDbsuk/005115268792275_1635814787236_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/S5QkoDbsuk/005115268792275_1635814787236_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"hAicM0Qams"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "StuR8dKjnJ",
			"guid": "StuR8dKjnJ",
			"title": "We Bought the CHEAPEST OLED TV… How Bad Could It Be?",
			"text": "<p>If you could get a 55\" OLED display for hundreds of dollars cheaper than usual, would you buy one? Should you buy one? We took the plunge for you and bought the Skyworth 55XC9000, come check out the results!</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"tooIKOkvbX"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 839,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-11-01T17:02:00.096Z",
			"likes": 384,
			"dislikes": 1,
			"score": 383,
			"comments": 68,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/StuR8dKjnJ/969485023950793_1635539800704.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/StuR8dKjnJ/969485023950793_1635539800704_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/StuR8dKjnJ/969485023950793_1635539800704_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"tooIKOkvbX"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "dKZfzQAKS7",
			"guid": "dKZfzQAKS7",
			"title": "How to Safely Try Windows 11 (SPONSORED)",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"9jzKspYmnV"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 981,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-31T19:04:00.024Z",
			"likes": 310,
			"dislikes": 17,
			"score": 293,
			"comments": 120,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/dKZfzQAKS7/528633932988806_1635559504916.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/dKZfzQAKS7/528633932988806_1635559504916_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/dKZfzQAKS7/528633932988806_1635559504916_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"9jzKspYmnV"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "kHfGeTC46e",
			"guid": "kHfGeTC46e",
			"title": "SC: Apple MackBook Pro - M1 Pro Version",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"0dlqSQwd3o"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 804,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-30T23:19:00.034Z",
			"likes": 438,
			"dislikes": 2,
			"score": 436,
			"comments": 90,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/kHfGeTC46e/361596549944581_1635543304998.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/kHfGeTC46e/361596549944581_1635543304998_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/kHfGeTC46e/361596549944581_1635543304998_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"0dlqSQwd3o"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "Whxnxrnxbf",
			"guid": "Whxnxrnxbf",
			"title": "Livestream VOD – October 29, 2021 @ 20:41 – We're Changing Our Name - WAN Show October 29, 2021",
			"text": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\">https://lmg.gg/SecretLabWAN</a></p><p><br /></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\">https://www.ridge.com/WAN</a></p><p><br /></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\">https://lmg.gg/Ktd7Z</a></p><p><br /></p><p>Podcast Download: TBD</p><p><br /></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br /></p><p>Timestamps TBD</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"v2ks4BurlU"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 7724,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-30T18:50:00.052Z",
			"likes": 171,
			"dislikes": 3,
			"score": 168,
			"comments": 94,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"v2ks4BurlU"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "tQ9pn1GBVv",
			"guid": "tQ9pn1GBVv",
			"title": "MA: Is the iPhone 13 good enough?",
			"text": "<p>Incremental updates can add up over the years, which is why it can seem like there’s not much new with the latest iPhone 13. But there is in fact a lot that has improved. We took Apple’s latest mainstream phone to the beach to see what you’re getting for your money.</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"2XpZqEKkZO"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 590,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-30T04:28:00.024Z",
			"likes": 244,
			"dislikes": 11,
			"score": 233,
			"comments": 53,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/tQ9pn1GBVv/543456272533431_1635566978421.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/tQ9pn1GBVv/543456272533431_1635566978421_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/tQ9pn1GBVv/543456272533431_1635566978421_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"2XpZqEKkZO"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "5q2wtjdvnv",
			"guid": "5q2wtjdvnv",
			"title": "TL: Facebook = Meta, Intel XeSS, 256-core EPYC + more!",
			"text": "<p><strong>NEWS SOURCES:</strong></p><p> </p><p>THE NEW META</p><p>Facebook rebrands company name</p><p>Because that’ll fix things <a href=\"https://gizmodo.com/facebook-has-no-clue-how-to-solve-its-image-problem-le-1847945657\">https://gizmodo.com/facebook-has-no-clue-how-to-solve-its-image-problem-le-1847945657</a></p><p>But John Carmack is skeptical <a href=\"https://www.gamesindustry.biz/articles/2021-10-29-oculus-john-carmack-skeptical-about-efforts-to-build-the-metaverse\">https://www.gamesindustry.biz/articles/2021-10-29-oculus-john-carmack-skeptical-about-efforts-to-build-the-metaverse</a></p><p><a href=\"https://www.youtube.com/watch?v=BnSUk0je6oo&amp;t=883s\">https://www.youtube.com/watch?v=BnSUk0je6oo&amp;t=883s</a></p><p>Quest won’t require FB accounts <a href=\"https://www.theverge.com/2021/10/28/22751297/meta-oculus-quest-need-facebook-account-login-password\">https://www.theverge.com/2021/10/28/22751297/meta-oculus-quest-need-facebook-account-login-password</a></p><p>Project Cambria headset <a href=\"https://techcrunch.com/2021/10/28/project-cambria-is-a-high-end-vr-headset-designed-for-facebooks-metaverse/?tpcc=tcplustwitter\">https://techcrunch.com/2021/10/28/project-cambria-is-a-high-end-vr-headset-designed-for-facebooks-metaverse/?tpcc=tcplustwitter</a></p><p>It’s the Oculus Pro <a href=\"https://twitter.com/Basti564/status/1452366595653869576\">https://twitter.com/Basti564/status/1452366595653869576</a></p><p>Meta Watch has a notch <a href=\"https://www.zdnet.com/article/meta-working-on-smartwatch-to-rival-apple-watch-says-bloomberg/\">https://www.zdnet.com/article/meta-working-on-smartwatch-to-rival-apple-watch-says-bloomberg/</a></p><p> </p><p>LOOKIN’ XESSY</p><p>Intel XeSS looks pretty good</p><p><a href=\"https://hexus.net/tech/news/graphics/148578-intel-xess-demonstrated-hitman-3-the-riftbreaker/\">https://hexus.net/tech/news/graphics/148578-intel-xess-demonstrated-hitman-3-the-riftbreaker/</a></p><p>Intel presentation <a href=\"https://www.youtube.com/watch?v=TP46fuSNhjI&amp;t=380s\">https://www.youtube.com/watch?v=TP46fuSNhjI&amp;t=380s</a></p><p>Intel’s Aurora supercomputer will be even more powerful than they thought, 2 ExaFLOPS</p><p><a href=\"https://linustechtips.com/topic/1384485-intel-ups-auroras-performance-to-2-exaflops-engages-in-zettaflops-race/\">https://linustechtips.com/topic/1384485-intel-ups-auroras-performance-to-2-exaflops-engages-in-zettaflops-race/</a></p><p><a href=\"https://www.tomshardware.com/uk/news/intel-ups-performance-of-aurora-to-2-exaflops\">https://www.tomshardware.com/uk/news/intel-ups-performance-of-aurora-to-2-exaflops</a></p><p><a href=\"https://www.nextplatform.com/2021/10/27/intel-aims-for-zettaflops-by-2027-pushes-aurora-above-2-exaflops/\">https://www.nextplatform.com/2021/10/27/intel-aims-for-zettaflops-by-2027-pushes-aurora-above-2-exaflops/</a></p><p> </p><p>CORE MULTIPLIER</p><p>AMD EPYC Turin CPUs could have 256 cores, 600W TDP</p><p>Genoa 96 cores <a href=\"https://www.tomshardware.com/news/zen4-madness-amd-epyc-genoa-with-96-cores-12-channel-ddr5-memory-and-avx-512\">https://www.tomshardware.com/news/zen4-madness-amd-epyc-genoa-with-96-cores-12-channel-ddr5-memory-and-avx-512</a></p><p><a href=\"https://www.kitguru.net/components/cpu/joao-silva/amd-epyc-turin-processors-may-come-with-up-to-256-cores-and-600w-ctdp/\">https://www.kitguru.net/components/cpu/joao-silva/amd-epyc-turin-processors-may-come-with-up-to-256-cores-and-600w-ctdp/</a></p><p><a href=\"https://twitter.com/ExecuFix/status/1453707924338089990\">https://twitter.com/ExecuFix/status/1453707924338089990</a></p><p><a href=\"https://hothardware.com/news/amd-epyc-turin-zen-5-cpu-256-cores-600w-tdp\">https://hothardware.com/news/amd-epyc-turin-zen-5-cpu-256-cores-600w-tdp</a></p><p> </p><p>QUICK BITS</p><p> </p><p>ENCRYPT ME IF U WANNA REACH ME</p><p>Google Fi adds E2E encrypted phone calls</p><p><a href=\"https://blog.google/products/google-fi/google-fi-end-to-end-encrypted-calls/\">https://blog.google/products/google-fi/google-fi-end-to-end-encrypted-calls/</a></p><p><a href=\"https://9to5google.com/2021/10/28/google-fi-encrypted-call/\">https://9to5google.com/2021/10/28/google-fi-encrypted-call/</a></p><p> </p><p>BETTER HIT THE GIM</p><p>DJI Ronin 4D camera has built-in gimbal</p><p><a href=\"https://linustechtips.com/topic/1384534-maybe-the-cameraman-looks-less-of-a-weirdo-now-dji-releases-camera-with-inbuilt-lidar-and-gimbal/\">https://linustechtips.com/topic/1384534-maybe-the-cameraman-looks-less-of-a-weirdo-now-dji-releases-camera-with-inbuilt-lidar-and-gimbal/</a></p><p><a href=\"https://youtu.be/V7DnNoAnbDc\">https://youtu.be/V7DnNoAnbDc</a></p><p><a href=\"https://www.techradar.com/news/i-spent-a-day-with-the-dji-ronin-4d-and-it-took-my-filmmaking-to-the-next-level\">https://www.techradar.com/news/i-spent-a-day-with-the-dji-ronin-4d-and-it-took-my-filmmaking-to-the-next-level</a></p><p> </p><p>LEMME FIX THAT FOR YOU</p><p>Microsoft finds macOS security flaw</p><p><a href=\"https://arstechnica.com/gadgets/2021/10/microsoft-reports-sip-bypassing-shrootless-vulnerability-in-macos/\">https://arstechnica.com/gadgets/2021/10/microsoft-reports-sip-bypassing-shrootless-vulnerability-in-macos/</a></p><p><a href=\"https://www.microsoft.com/security/blog/2021/10/28/microsoft-finds-new-macos-vulnerability-shrootless-that-could-bypass-system-integrity-protection/\">https://www.microsoft.com/security/blog/2021/10/28/microsoft-finds-new-macos-vulnerability-shrootless-that-could-bypass-system-integrity-protection/</a></p><p> </p><p>P.LAYSTATION C.OMPUTER</p><p>Playstation is all in on PC, creates publishing unit</p><p><a href=\"https://www.pcgamer.com/sony-creates-playstation-pc-publishing-label/\">https://www.pcgamer.com/sony-creates-playstation-pc-publishing-label/</a></p><p><a href=\"https://www.videogameschronicle.com/news/sony-has-formed-the-playstation-pc-label-for-its-pc-games-push/\">https://www.videogameschronicle.com/news/sony-has-formed-the-playstation-pc-label-for-its-pc-games-push/</a></p><p><a href=\"https://twitter.com/MatPiscatella/status/1453722573263364108\\\">https://twitter.com/MatPiscatella/status/1453722573263364108\\</a></p><p> </p><p>PEW PEW, HEH, OH GOD RUN</p><p>Boeing and General Atomics will develop 300kW laser for the Army</p><p><a href=\"https://www.engadget.com/us-army-ga-ems-boeing-300-kw-laser-154817777.html\">https://www.engadget.com/us-army-ga-ems-boeing-300-kw-laser-154817777.html</a></p><p><a href=\"https://www.ga.com/ga-ems-and-boeing-team-to-develop-300kw-class-helws-prototype-for-us-army\">https://www.ga.com/ga-ems-and-boeing-team-to-develop-300kw-class-helws-prototype-for-us-army</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"haF82MrCle"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 388,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-30T02:20:00.054Z",
			"likes": 168,
			"dislikes": 0,
			"score": 168,
			"comments": 21,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/5q2wtjdvnv/840347515819536_1635556021179.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/5q2wtjdvnv/840347515819536_1635556021179_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/5q2wtjdvnv/840347515819536_1635556021179_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"haF82MrCle"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "QiCZYzAurx",
			"guid": "QiCZYzAurx",
			"title": "The Best Custom Gaming PC is… a PRE-BUILT??",
			"text": "<p>With graphics cards still being so hard to come by, even if you really like building computers should you stoop to buying a prebuilt if you're looking to upgrade in the current market?</p><p><br /></p><p>Thanks to Seasonic for sponsoring this video! Learn more about Seasonic Power Supplies at <a href=\"https://geni.us/Jm38GO5\">https://geni.us/Jm38GO5</a></p><p><br /></p><p>Buy Seasonic FOCUS Gold 750W PSU</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/dAe5FuO\">https://geni.us/dAe5FuO</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/PXyh\">https://geni.us/PXyh</a></p><p><br /></p><p>Buy ASUS G15 DK Pre-Built PC</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/ZqsgF\">https://geni.us/ZqsgF</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/XAdvW\">https://geni.us/XAdvW</a></p><p><br /></p><p>Buy CyberPowerPC Pre-Build PCs</p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/4zpz5\">https://geni.us/4zpz5</a></p><p><br /></p><p>Buy ASUS Dual GeForce RTX 3070 GPU</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/6c9q79\">https://geni.us/6c9q79</a></p><p>On B&amp;H (PAID LINK): <a href=\"https://geni.us/FSrzy9\">https://geni.us/FSrzy9</a></p><p><br /></p><p>Buy Cooler Master Hyper 212 CPU Cooler</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/HFDO\">https://geni.us/HFDO</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/z85XAV\">https://geni.us/z85XAV</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/Ns06\">https://geni.us/Ns06</a></p><p><br /></p><p>Buy AMD Ryzen 7 5800X CPU</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/l2inX3\">https://geni.us/l2inX3</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/sYw8iW\">https://geni.us/sYw8iW</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/Xf8lhE\">https://geni.us/Xf8lhE</a></p><p><br /></p><p>Buy ASUS ROG Strix B450-F Gaming II</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/K9iWS\">https://geni.us/K9iWS</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/2FG6B\">https://geni.us/2FG6B</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/Chx2\">https://geni.us/Chx2</a></p><p><br /></p><p>Buy G.Skill RipJaws V Series 16GB (2 x 8GB) DDR4 RAM</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/PugVfj\">https://geni.us/PugVfj</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/jUte\">https://geni.us/jUte</a></p><p><br /></p><p>Buy Western Digital 2TB WD Blue SATA SSD</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/MUPmjK\">https://geni.us/MUPmjK</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/AAOjaN\">https://geni.us/AAOjaN</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/IVkcLF\">https://geni.us/IVkcLF</a></p><p><br /></p><p>Buy Crucial P2 500GB NVMe SSD</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/89n4AgY\">https://geni.us/89n4AgY</a></p><p>On Best Buy (PAID LINK): <a href=\"https://geni.us/jpVpZcI\">https://geni.us/jpVpZcI</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/P5tuRto\">https://geni.us/P5tuRto</a></p><p><br /></p><p>Buy Phanteks P400A</p><p>On Amazon (PAID LINK): <a href=\"https://geni.us/syBWBls\">https://geni.us/syBWBls</a></p><p>On Newegg (PAID LINK): <a href=\"https://geni.us/QzYQUL\">https://geni.us/QzYQUL</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"G9ypsbtDus"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 703,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-30T00:01:00.048Z",
			"likes": 342,
			"dislikes": 4,
			"score": 338,
			"comments": 66,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/QiCZYzAurx/429703473663923_1635549860159.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/QiCZYzAurx/429703473663923_1635549860159_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/QiCZYzAurx/429703473663923_1635549860159_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"G9ypsbtDus"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "rOl3QLi2xa",
			"guid": "rOl3QLi2xa",
			"title": "SC: Teracube Smartphone - CHARITY TeamSeas",
			"text": "<p>Help remove trash from our oceans, beaches, and rivers with TeamSeas! Donate on YouTube or head to <a href=\"https://lmg.gg/Teamseas\">https://lmg.gg/Teamseas</a></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"WyuxFSG8z4"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 911,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-29T20:22:00.020Z",
			"likes": 234,
			"dislikes": 0,
			"score": 234,
			"comments": 46,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/rOl3QLi2xa/310028752988458_1635466397540.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/rOl3QLi2xa/310028752988458_1635466397540_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/rOl3QLi2xa/310028752988458_1635466397540_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"WyuxFSG8z4"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "1hqk3wqkyA",
			"guid": "1hqk3wqkyA",
			"title": "TJM: The Babadook",
			"text": "<p>Sarah joins in to lend her Horror expertise on the 2014 Australian psychological horror film, The Babadook. And wow, this is one of our most divisive episodes ever!</p><p>The next episode will be: Last Night in Soho (Edgar Wright, 2021)</p><p>Twitter: <a href=\"https://twitter.com/TJMpod\">https://twitter.com/TJMpod</a></p><p>Email: hello@theyrejustmovies.com</p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"lYug3Ykmyn",
				"pFlyYNMhEv"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 4009,
				"hasAudio": true,
				"audioCount": 1,
				"audioDuration": 4003,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-29T18:36:00.059Z",
			"likes": 28,
			"dislikes": 0,
			"score": 28,
			"comments": 12,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/1hqk3wqkyA/376134128766182_1635436402063.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/1hqk3wqkyA/376134128766182_1635436402063_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/1hqk3wqkyA/376134128766182_1635436402063_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"lYug3Ykmyn"
			],
			"audioAttachments": [
				"pFlyYNMhEv"
			],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "eBydP4RMRk",
			"guid": "eBydP4RMRk",
			"title": "TQ: Windows 11 Settings You Should Change",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"Ikz2VctkCl"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 229,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-29T18:27:00.049Z",
			"likes": 168,
			"dislikes": 5,
			"score": 163,
			"comments": 62,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/eBydP4RMRk/842354136541091_1635531025956.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/eBydP4RMRk/842354136541091_1635531025956_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/eBydP4RMRk/842354136541091_1635531025956_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"Ikz2VctkCl"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		},
		{
			"id": "UhBJouqTej",
			"guid": "UhBJouqTej",
			"title": "SC: Apple Watch 7",
			"text": "<p><br /></p>",
			"type": "blogPost",
			"tags": [],
			"attachmentOrder": [
				"2knUnyS0V0"
			],
			"metadata": {
				"hasVideo": true,
				"videoCount": 1,
				"videoDuration": 585,
				"hasAudio": false,
				"audioCount": 0,
				"audioDuration": 0,
				"hasPicture": false,
				"pictureCount": 0,
				"hasGallery": false,
				"galleryCount": 0,
				"isFeatured": false
			},
			"releaseDate": "2021-10-29T17:49:00.029Z",
			"likes": 321,
			"dislikes": 3,
			"score": 318,
			"comments": 51,
			"creator": {
				"id": "59f94c0bdd241b70349eb72b",
				"owner": {
					"id": "59f94c0bdd241b70349eb723",
					"username": "Linus"
				},
				"title": "LinusTechTips",
				"urlname": "linustechtips",
				"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
				"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
				"category": {
					"title": "Technology"
				},
				"cover": {
					"width": 1990,
					"height": 519,
					"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867.jpeg",
					"childImages": [
						{
							"width": 1245,
							"height": 325,
							"path": "https://pbs.floatplane.com/cover_images/59f94c0bdd241b70349eb72b/696951209272749_1521668313867_1245x325.jpeg"
						}
					]
				},
				"icon": {
					"width": 600,
					"height": 600,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
					"childImages": [
						{
							"width": 250,
							"height": 250,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
						},
						{
							"width": 100,
							"height": 100,
							"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
						}
					]
				},
				"liveStream": {
					"id": "5c13f3c006f1be15e08e05c0",
					"title": "We're Changing Our Name - WAN Show October 29, 2021",
					"description": "<p>Check out Secret Lab at <a href=\"https://lmg.gg/SecretLabWAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/SecretLabWAN</a></p><p><br></p><p>Save 10% at Ridage Wallet with offer code WAN at <a href=\"https://www.ridge.com/WAN\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.ridge.com/WAN</a></p><p><br></p><p>Try Pulseway for free and start remotely monitoring and managing your server or PC at <a href=\"https://lmg.gg/Ktd7Z\" rel=\"noopener noreferrer\" target=\"_blank\">https://lmg.gg/Ktd7Z</a></p><p><br></p><p>Podcast Download: TBD</p><p><br></p><p>Check out our other Podcasts:</p><p>They're Just Movies Podcast: <a href=\"https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA\" rel=\"noopener noreferrer\" target=\"_blank\">https://www.youtube.com/channel/UCt-oJR5teQIjOAxCmIQvcgA</a></p><p><br></p><p>Timestamps TBD</p>",
					"thumbnail": {
						"width": 1920,
						"height": 1080,
						"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
						"childImages": [
							{
								"width": 400,
								"height": 225,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_400x225.jpeg"
							},
							{
								"width": 1200,
								"height": 675,
								"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724_1200x675.jpeg"
							}
						]
					},
					"owner": "59f94c0bdd241b70349eb72b",
					"streamPath": "/api/video/v1/us-east-1.758417551536.channel.yKkxur4ukc0B.m3u8",
					"offline": {
						"title": "Offline",
						"description": "We're offline for now – please check back later!",
						"thumbnail": {
							"width": 1920,
							"height": 1080,
							"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026.jpeg",
							"childImages": [
								{
									"width": 400,
									"height": 225,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"
								},
								{
									"width": 1200,
									"height": 675,
									"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_1200x675.jpeg"
								}
							]
						}
					}
				},
				"subscriptionPlans": [
					{
						"id": "5d48d0306825b5780db93d07",
						"title": "LTT Supporter (1080p)",
						"description": "Includes:\n- Early access (when possible)\n- Live Streaming\n- Behind-the-scenes, cutting room floor & exclusives\n\nNOTE: Tech Quickie and TechLinked are included for now, but will move to their own Floatplane pages in the future",
						"price": "5.00",
						"priceYearly": "50.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": true,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					},
					{
						"id": "5e0ba6ac14e2590f760a0f0f",
						"title": "LTT Supporter Plus",
						"description": "You are the real MVP. \n\nYour support helps us continue to build out our team, drive up production values, run experiments that might lose money for a long time (*cough* LTX *cough*) and otherwise be the best content creators we can be.\n\nThis tier includes all the perks of the previous ones, but at floatplane's glorious high bitrate 4K!",
						"price": "10.00",
						"priceYearly": "100.00",
						"currency": "usd",
						"logo": null,
						"interval": "month",
						"featured": false,
						"allowGrandfatheredAccess": false,
						"discordServers": [],
						"discordRoles": []
					}
				],
				"discoverable": true,
				"subscriberCountDisplay": "total",
				"incomeDisplay": false,
				"card": {
					"width": 375,
					"height": 500,
					"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871.jpeg",
					"childImages": [
						{
							"width": 300,
							"height": 400,
							"path": "https://pbs.floatplane.com/creator_card/59f94c0bdd241b70349eb72b/281467946609369_1551250329871_300x400.jpeg"
						}
					]
				}
			},
			"wasReleasedSilently": false,
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/blogPost_thumbnails/UhBJouqTej/296904045754353_1635526021427.jpeg",
				"childImages": [
					{
						"width": 400,
						"height": 225,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/UhBJouqTej/296904045754353_1635526021427_400x225.jpeg"
					},
					{
						"width": 1200,
						"height": 675,
						"path": "https://pbs.floatplane.com/blogPost_thumbnails/UhBJouqTej/296904045754353_1635526021427_1200x675.jpeg"
					}
				]
			},
			"isAccessible": true,
			"videoAttachments": [
				"2knUnyS0V0"
			],
			"audioAttachments": [],
			"pictureAttachments": [],
			"galleryAttachments": []
		}
	],
	"lastElements": [
		{
			"creatorId": "59f94c0bdd241b70349eb72b",
			"blogPostId": "UhBJouqTej",
			"moreFetchable": true
		}
	]
}
"""#
	
	static let getBlogPost = #"""
{
	"id": "Dw2ms0AgL8",
	"guid": "Dw2ms0AgL8",
	"title": "Livestream VOD – October 9, 2021 @ 07:18 – First Linux Stream",
	"text": "<p>Check out the MiSTer Multisystem at <a href=\"https://rmcretro.store/multisystem-board-only/\">https://rmcretro.store/multisystem-board-only/</a></p>",
	"type": "blogPost",
	"tags":[
		"test1",
		"longertest"
	],
	"attachmentOrder": [
		"TViGzkuIic"
	],
	"metadata": {
		"hasVideo": true,
		"videoCount": 1,
		"videoDuration": 5689,
		"hasAudio": false,
		"audioCount": 0,
		"audioDuration": 0,
		"hasPicture": false,
		"pictureCount": 0,
		"hasGallery": false,
		"galleryCount": 0,
		"isFeatured": false
	},
	"releaseDate": "2021-10-09T09:29:00.039Z",
	"likes": 41,
	"dislikes": 0,
	"score": 41,
	"comments": 28,
	"creator": {
		"id": "59f94c0bdd241b70349eb72b",
		"owner": "59f94c0bdd241b70349eb723",
		"title": "LinusTechTips",
		"urlname": "linustechtips",
		"description": "We make entertaining videos about technology, including tech reviews, showcases and other content.",
		"about": "# We're LinusTechTips\nWe make videos and stuff, cool eh?",
		"category": "59f94c0bdd241b70349eb727",
		"cover": null,
		"icon": {
			"width": 600,
			"height": 600,
			"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205.jpeg",
			"childImages": [
				{
					"width": 250,
					"height": 250,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_250x250.jpeg"
				},
				{
					"width": 100,
					"height": 100,
					"path": "https://pbs.floatplane.com/creator_icons/59f94c0bdd241b70349eb72b/770551996990709_1551249357205_100x100.jpeg"
				}
			]
		},
		"liveStream": null,
		"subscriptionPlans": null,
		"discoverable": true,
		"subscriberCountDisplay": "total",
		"incomeDisplay": false
	},
	"wasReleasedSilently": true,
	"thumbnail": {
		"width": 1200,
		"height": 675,
		"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/084281881402899_1633761128412.jpeg",
		"childImages": [
			{
				"width": 400,
				"height": 225,
				"path": "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/084281881402899_1633761128412_400x225.jpeg"
			}
		]
	},
	"isAccessible": true,
	"userInteraction": [],
	"videoAttachments": [
		{
			"id": "TViGzkuIic",
			"guid": "TViGzkuIic",
			"title": "October 9, 2021 @ 07:18 – First Linux Stream",
			"type": "video",
			"description": "",
			"releaseDate": null,
			"duration": 5689,
			"creator": "59f94c0bdd241b70349eb72b",
			"likes": 0,
			"dislikes": 0,
			"score": 0,
			"isProcessing": false,
			"primaryBlogPost": "Dw2ms0AgL8",
			"thumbnail": {
				"width": 1920,
				"height": 1080,
				"path": "https://pbs.floatplane.com/content_thumbnails/TViGzkuIic/324783659287024_1633769709593.jpeg",
				"childImages": []
			},
			"isAccessible": true
		}
	],
	"audioAttachments": [
		{
			"id": "iGssjNGPSD",
			"guid": "iGssjNGPSD",
			"title": "Robocop FP.mp3",
			"type": "audio",
			"description": "",
			"duration": 4165,
			"waveform": {
				"dataSetLength": 1000,
				"highestValue": 108,
				"lowestValue": 8,
				"data": [
					71,
					50,
					69,
					61,
					54,
					59,
					54,
					73,
					72,
					47,
					67,
					60,
					37,
					32,
					60,
					49,
					31,
					37,
					34,
					60,
					55,
					50,
					59,
					59,
					49,
					74,
					42,
					27,
					33,
					33,
					41,
					37,
					60,
					46,
					33,
					47,
					55,
					49,
					40,
					39,
					40,
					27,
					52,
					43,
					40,
					58,
					60,
					81,
					49,
					41,
					59,
					36,
					70,
					55,
					25,
					64,
					53,
					61,
					66,
					73,
					61,
					51,
					44,
					52,
					62,
					65,
					35,
					55,
					43,
					56,
					83,
					74,
					56,
					66,
					50,
					41,
					53,
					43,
					74,
					47,
					42,
					44,
					58,
					54,
					40,
					51,
					57,
					49,
					53,
					46,
					31,
					57,
					57,
					78,
					69,
					72,
					84,
					86,
					88,
					60,
					67,
					49,
					53,
					92,
					60,
					47,
					50,
					64,
					62,
					32,
					66,
					40,
					29,
					57,
					55,
					74,
					49,
					31,
					42,
					29,
					42,
					43,
					64,
					42,
					52,
					39,
					45,
					67,
					78,
					43,
					51,
					81,
					63,
					74,
					80,
					90,
					63,
					39,
					59,
					40,
					64,
					56,
					97,
					53,
					90,
					87,
					45,
					31,
					74,
					58,
					46,
					51,
					70,
					39,
					42,
					39,
					44,
					66,
					52,
					38,
					33,
					55,
					50,
					42,
					90,
					45,
					32,
					48,
					42,
					31,
					46,
					39,
					56,
					55,
					44,
					39,
					32,
					63,
					61,
					52,
					64,
					49,
					38,
					46,
					68,
					35,
					50,
					64,
					60,
					67,
					49,
					52,
					47,
					36,
					37,
					45,
					39,
					54,
					40,
					27,
					20,
					54,
					29,
					32,
					31,
					46,
					52,
					75,
					61,
					68,
					54,
					61,
					35,
					37,
					24,
					42,
					42,
					43,
					44,
					37,
					29,
					45,
					40,
					26,
					53,
					31,
					30,
					39,
					56,
					87,
					53,
					58,
					75,
					60,
					42,
					28,
					30,
					23,
					26,
					36,
					23,
					60,
					44,
					50,
					40,
					48,
					42,
					36,
					32,
					49,
					46,
					43,
					45,
					43,
					24,
					24,
					69,
					35,
					43,
					54,
					42,
					55,
					29,
					31,
					33,
					27,
					31,
					30,
					17,
					19,
					17,
					20,
					42,
					66,
					36,
					46,
					31,
					32,
					22,
					29,
					37,
					45,
					58,
					34,
					32,
					68,
					54,
					43,
					45,
					39,
					57,
					39,
					68,
					36,
					20,
					49,
					61,
					32,
					42,
					58,
					70,
					59,
					52,
					79,
					43,
					49,
					56,
					43,
					55,
					42,
					35,
					38,
					12,
					43,
					42,
					43,
					58,
					56,
					51,
					49,
					29,
					69,
					77,
					77,
					46,
					38,
					23,
					26,
					33,
					48,
					44,
					44,
					35,
					42,
					81,
					93,
					55,
					40,
					37,
					54,
					53,
					56,
					28,
					37,
					98,
					63,
					23,
					38,
					39,
					71,
					57,
					21,
					26,
					63,
					108,
					43,
					27,
					31,
					42,
					46,
					47,
					45,
					38,
					15,
					75,
					69,
					51,
					51,
					61,
					67,
					45,
					40,
					48,
					77,
					49,
					25,
					38,
					65,
					52,
					58,
					86,
					82,
					77,
					92,
					58,
					40,
					59,
					79,
					55,
					60,
					34,
					48,
					42,
					30,
					35,
					24,
					40,
					32,
					34,
					36,
					29,
					27,
					40,
					35,
					32,
					46,
					53,
					38,
					53,
					62,
					47,
					40,
					36,
					29,
					30,
					28,
					27,
					42,
					36,
					36,
					16,
					23,
					25,
					68,
					35,
					36,
					45,
					19,
					34,
					49,
					44,
					24,
					43,
					37,
					73,
					32,
					32,
					31,
					25,
					31,
					38,
					35,
					33,
					41,
					43,
					49,
					34,
					45,
					36,
					32,
					40,
					45,
					24,
					36,
					34,
					51,
					71,
					53,
					61,
					64,
					62,
					59,
					46,
					102,
					64,
					45,
					78,
					77,
					99,
					57,
					44,
					64,
					51,
					45,
					35,
					33,
					27,
					52,
					25,
					21,
					25,
					36,
					27,
					37,
					55,
					60,
					31,
					42,
					40,
					32,
					25,
					54,
					49,
					45,
					36,
					34,
					39,
					67,
					67,
					57,
					71,
					66,
					56,
					44,
					55,
					30,
					46,
					29,
					53,
					46,
					40,
					52,
					35,
					44,
					45,
					35,
					33,
					60,
					49,
					75,
					64,
					45,
					35,
					23,
					41,
					31,
					29,
					47,
					30,
					47,
					39,
					23,
					36,
					30,
					31,
					65,
					44,
					56,
					37,
					81,
					69,
					84,
					70,
					53,
					44,
					32,
					51,
					33,
					43,
					37,
					61,
					39,
					25,
					64,
					43,
					27,
					53,
					37,
					36,
					33,
					42,
					44,
					78,
					104,
					70,
					64,
					50,
					26,
					27,
					57,
					81,
					59,
					81,
					51,
					48,
					43,
					35,
					56,
					39,
					53,
					73,
					65,
					33,
					48,
					29,
					42,
					47,
					44,
					34,
					76,
					56,
					42,
					35,
					29,
					82,
					63,
					39,
					24,
					34,
					9,
					52,
					44,
					30,
					62,
					53,
					52,
					45,
					60,
					44,
					35,
					33,
					74,
					52,
					33,
					83,
					42,
					28,
					46,
					29,
					48,
					44,
					44,
					50,
					33,
					49,
					65,
					40,
					71,
					34,
					48,
					73,
					31,
					57,
					53,
					23,
					42,
					43,
					42,
					46,
					76,
					34,
					35,
					54,
					43,
					34,
					35,
					28,
					26,
					43,
					45,
					48,
					38,
					35,
					37,
					43,
					39,
					33,
					36,
					30,
					51,
					53,
					32,
					32,
					70,
					36,
					34,
					42,
					49,
					48,
					37,
					42,
					47,
					63,
					84,
					38,
					36,
					26,
					38,
					35,
					30,
					35,
					46,
					46,
					30,
					33,
					26,
					30,
					31,
					40,
					23,
					17,
					41,
					30,
					28,
					31,
					32,
					30,
					54,
					34,
					63,
					58,
					38,
					56,
					68,
					55,
					47,
					32,
					49,
					51,
					90,
					37,
					46,
					41,
					53,
					30,
					50,
					84,
					50,
					61,
					34,
					22,
					45,
					41,
					74,
					35,
					76,
					47,
					22,
					32,
					38,
					77,
					73,
					59,
					84,
					55,
					91,
					53,
					39,
					54,
					61,
					35,
					39,
					34,
					39,
					68,
					61,
					73,
					52,
					44,
					24,
					56,
					84,
					90,
					86,
					91,
					61,
					66,
					49,
					38,
					43,
					89,
					35,
					40,
					55,
					37,
					62,
					42,
					41,
					29,
					37,
					27,
					43,
					67,
					32,
					21,
					16,
					54,
					18,
					34,
					44,
					49,
					34,
					58,
					50,
					27,
					31,
					39,
					40,
					54,
					50,
					64,
					25,
					30,
					34,
					31,
					27,
					28,
					29,
					31,
					24,
					31,
					28,
					52,
					38,
					27,
					30,
					52,
					35,
					53,
					40,
					47,
					33,
					54,
					47,
					43,
					33,
					22,
					41,
					25,
					14,
					41,
					46,
					53,
					32,
					35,
					49,
					33,
					77,
					32,
					62,
					46,
					44,
					24,
					33,
					18,
					59,
					58,
					51,
					47,
					39,
					46,
					56,
					35,
					25,
					40,
					35,
					35,
					57,
					43,
					47,
					23,
					29,
					55,
					57,
					28,
					50,
					36,
					60,
					35,
					55,
					83,
					56,
					25,
					18,
					50,
					46,
					50,
					70,
					44,
					46,
					45,
					58,
					39,
					31,
					29,
					21,
					18,
					53,
					67,
					65,
					67,
					48,
					34,
					67,
					88,
					73,
					30,
					26,
					42,
					58,
					69,
					50,
					39,
					36,
					99,
					72,
					43,
					101,
					99,
					61,
					69,
					70,
					83,
					69,
					49,
					33,
					38,
					33,
					30,
					27,
					23,
					88,
					90,
					40,
					48,
					70,
					93,
					69,
					52,
					52,
					43,
					88,
					61,
					46,
					46,
					45,
					43,
					68,
					53,
					60,
					61,
					54,
					37,
					37,
					43,
					36,
					38,
					35,
					52,
					45,
					48,
					46,
					36,
					33,
					33,
					28,
					33,
					26,
					29,
					34,
					29,
					36,
					43,
					30,
					42,
					36,
					35,
					24,
					42,
					70,
					65,
					48,
					41,
					34,
					75,
					77,
					61,
					39,
					62,
					88,
					54,
					59,
					52,
					42,
					40,
					28,
					43,
					33,
					43,
					84,
					44,
					66,
					47,
					22,
					56,
					61,
					32,
					33,
					64,
					37,
					83,
					80,
					51,
					49,
					51,
					22,
					40,
					52,
					41,
					8
				]
			},
			"creator": "59f94c0bdd241b70349eb72b",
			"likes": 0,
			"dislikes": 0,
			"score": 0,
			"isProcessing": false,
			"primaryBlogPost": "jVU2y9PlnG",
			"isAccessible": true
		}
	],
	"pictureAttachments": [
		{
			"id": "I5CykP2MQj",
			"guid": "I5CykP2MQj",
			"title": "Robo Plouffe",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/I5CykP2MQj/899812577760249_1634845037236.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "UNn7fDuIGw",
			"guid": "UNn7fDuIGw",
			"title": "David the Tron star",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/UNn7fDuIGw/465183837558247_1634845039163.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "ZWKdCy8TMN",
			"guid": "ZWKdCy8TMN",
			"title": "\"I hate costumes\" Jonathan",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/ZWKdCy8TMN/239212458322156_1634845035660.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "c1GNdRXg6w",
			"guid": "c1GNdRXg6w",
			"title": "cheer squad Ed",
			"type": "picture",
			"description": "Ed he's our man, if he can't do it no one can!",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/c1GNdRXg6w/199273375778825_1634845060513.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "epGZloSntp",
			"guid": "epGZloSntp",
			"title": "\"The Fappening\" James",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/epGZloSntp/490375769004655_1634845033123.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "l4n4cHm7eg",
			"guid": "l4n4cHm7eg",
			"title": "David the Tron cowboy",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/l4n4cHm7eg/938164974758105_1634845054302.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "uAudv19Gtd",
			"guid": "uAudv19Gtd",
			"title": "Andy as Linus",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/uAudv19Gtd/090538718112325_1634845040773.jpeg",
				"childImages": []
			},
			"isAccessible": true
		},
		{
			"id": "xFsKuYy46A",
			"guid": "xFsKuYy46A",
			"title": "FP EX: bad Costume video images",
			"type": "picture",
			"description": "",
			"likes": 1,
			"dislikes": 0,
			"score": 1,
			"isProcessing": false,
			"creator": "59f94c0bdd241b70349eb72b",
			"primaryBlogPost": "PGZBzzRWpD",
			"thumbnail": {
				"width": 1200,
				"height": 675,
				"path": "https://pbs.floatplane.com/picture_thumbnails/xFsKuYy46A/163892113852418_1634845028805.jpeg",
				"childImages": []
			},
			"isAccessible": true
		}
	],
	"galleryAttachments": []
}
"""#
	
	static let getVideoContent = #"""
{
	"id": "TViGzkuIic",
	"guid": "TViGzkuIic",
	"title": "October 9, 2021 @ 07:18 – First Linux Stream",
	"type": "video",
	"description": "",
	"releaseDate": null,
	"duration": 5689,
	"creator": "59f94c0bdd241b70349eb72b",
	"likes": 0,
	"dislikes": 0,
	"score": 0,
	"isProcessing": false,
	"primaryBlogPost": "Dw2ms0AgL8",
	"thumbnail": {
		"width": 1920,
		"height": 1080,
		"path": "https://pbs.floatplane.com/content_thumbnails/TViGzkuIic/324783659287024_1633769709593.jpeg",
		"childImages": []
	},
	"isAccessible": true,
	"blogPosts": [
		"Dw2ms0AgL8"
	],
	"timelineSprite": {
		"width": 4960,
		"height": 2610,
		"path": "https://pbs.floatplane.com/timeline_sprite/TViGzkuIic/142493855372807_1633769996492.jpeg",
		"childImages": []
	},
	"userInteraction": [],
	"levels": [
		{
			"name": "360",
			"width": 640,
			"height": 360,
			"label": "360p",
			"order": 0
		},
		{
			"name": "480",
			"width": 854,
			"height": 480,
			"label": "480p",
			"order": 1
		},
		{
			"name": "720",
			"width": 1280,
			"height": 720,
			"label": "720p",
			"order": 2
		}
	]
}
"""#
	static let getCdn: String = #"""
{
	"cdn": "https://cdn-vod-drm2.floatplane.com",
	"strategy": "cdn",
	"resource": {
		"uri": "/Videos/TViGzkuIic/{qualityLevels}.mp4/chunk.m3u8?token={qualityLevelParams.token}",
		"data": {
			"qualityLevels": [
				{
					"name": "360",
					"width": 640,
					"height": 360,
					"label": "360p",
					"order": 0
				},
				{
					"name": "480",
					"width": 854,
					"height": 480,
					"label": "480p",
					"order": 1
				},
				{
					"name": "720",
					"width": 1280,
					"height": 720,
					"label": "720p",
					"order": 2
				},
				{
					"name": "1080",
					"width": 2160,
					"height": 1080,
					"label": "1080p",
					"order": 4
				}
			],
			"qualityLevelParams": {
				"360": {
					"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNzb3VyY2VQYXRoIjoiL1ZpZGVvcy9UVmlHemt1SWljLzM2MC5tcDQvY2h1bmsubTN1OCIsInVzZXJJZCI6IjAxMjM0NTY3ODlhYmNkZWYwMTIzNDU2NyIsImlhdCI6MTYzMzc5NzMxMSwiZXhwIjoxNjMzODE4OTExfQ.uaLzZ4wSc0jrYbjkdhuF4_UY92iWQsq2efrWUutYUvQ"
				},
				"480": {
					"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNzb3VyY2VQYXRoIjoiL1ZpZGVvcy9UVmlHemt1SWljLzQ4MC5tcDQvY2h1bmsubTN1OCIsInVzZXJJZCI6IjAxMjM0NTY3ODlhYmNkZWYwMTIzNDU2NyIsImlhdCI6MTYzMzc5NzMxMSwiZXhwIjoxNjMzODE4OTExfQ.O6PHCJKcLW7ohuKj6UcMa8QGoN-vZr6xTtfXsUMRki0"
				},
				"720": {
					"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNzb3VyY2VQYXRoIjoiL1ZpZGVvcy9UVmlHemt1SWljLzcyMC5tcDQvY2h1bmsubTN1OCIsInVzZXJJZCI6IjAxMjM0NTY3ODlhYmNkZWYwMTIzNDU2NyIsImlhdCI6MTYzMzc5NzMxMSwiZXhwIjoxNjMzODE4OTExfQ.lbOTTBXBjA-i9gBzm8ydFQ8fa8q07Z2vaLsYMKUp4Ik"
				},
				"1080": {
					"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNzb3VyY2VQYXRoIjoiL1ZpZGVvcy9UVmlHemt1SWljLzEwODAubXA0L2NodW5rLm0zdTgiLCJ1c2VySWQiOiIwMTIzNDU2Nzg5YWJjZGVmMDEyMzQ1NjciLCJpYXQiOjE2MzM3OTczMTEsImV4cCI6MTYzMzgxODkxMX0.E-bw_gnUzKUpYeL2l-kTmj5CbwmDb519ohjf5LlLyQg"
				}
			}
		}
	}
}
"""#
	
	static let getPictureContent: String = #"""
{"id":"ZWKdCy8TMN","guid":"ZWKdCy8TMN","title":"\"I hate costumes\" Jonathan","type":"picture","description":"","likes":1,"dislikes":0,"score":1,"isProcessing":false,"creator":"59f94c0bdd241b70349eb72b","primaryBlogPost":"PGZBzzRWpD","userInteraction":[],"thumbnail":{"width":1200,"height":675,"path":"https://pbs.floatplane.com/picture_thumbnails/ZWKdCy8TMN/239212458322156_1634845035660.jpeg","childImages":[]},"isAccessible":true,"imageFiles":[{"path":"https://pbs.floatplane.com/content_images/59f94c0bdd241b70349eb72b/465975275316873_1634845031494_1164x675.jpeg?AWSAccessKeyId=EG5Q4HESM1NW88XSD867&Expires=1641160871&Signature=Qn8hXrBOS%2Fee18aqjHqD8uFAfjw%3D","width":1164,"height":675,"size":165390}]}
"""#
}
