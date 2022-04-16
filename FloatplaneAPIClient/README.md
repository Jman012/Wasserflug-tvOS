# Swift5 API client for FloatplaneAPIClient

Homepage: [https://jman012.github.io/FloatplaneAPIDocs](https://jman012.github.io/FloatplaneAPIDocs)

This document describes the API layer of [https://www.floatplane.com](https://www.floatplane.com), a content creation and video streaming website created by Floatplane Media Inc. and Linus Media Group, where users can support their favorite creates via paid subscriptions in order to watch their video and livestream content in higher quality and other perks.

While this document contains stubs for all of the Floatplane APIs for this version, many are not filled out because they are related only to content creation, moderation, or administration and are not needed for regular use. These have \"TODO\" as the description, and are automatically removed before document generation. If you are viewing the \"Trimmed\" version of this document, they have been removed for brevity.

## API Object Organization

- **Users** and **Creators** exist on Floatplane at the highest level
 - The highest-level object in Floatplane is the Creator. This is an entity, such as Linus Tech Tips, that produces media for Users.
- A Creator owns one or more **Subscription Plans**
- A User can view a Creator's Content if they are subscribed to them
- A Creator publishes **Content**, in the form of **Blog Posts**
 - Content is produced by Creators, and show up for subscribed Users to view when it is released. A piece of Content is meant to be generic, and may contain different types of sub-Content. Currently, the only type is a Blog Post.
 - A Blog Post is the main type of Content that a Creator produces. Blog Posts are how a Creator can share text and/or media attachments with their subscribers.
- A Blog Post is comprised of one or more of: video, audio, picture, or gallery **Attachments**
 - A media Attachment may be: video, audio, picture, gallery. Attachments are a part of Blog Posts, and are in a particular order.
- A Creator may also have a single **Livestream**

## API Flow

As of Floatplane version 3.5.1, these are the recommended endpoints to use for normal operations.

1. Login
 1. `/api/v3/auth/captcha/info` - Get captcha information
 1. `/api/v2/auth/login` - Login with username, password, and optional captcha token
 1. `/api/v2/auth/checkFor2faLogin` - Optionally provide 2FA token to complete login
 1. `/api/v2/auth/logout` - Logout at a later point in time
1. Home page
 1. `/api/v3/user/subscriptions` - Get the user's active subscriptions
 1. `/api/v3/content/creator/list` - Using the subscriptions, show a home page with content from all subscriptions
  1. Supply all creator identifiers from the subscriptions
  1. This should be paginated
 1. `/api/v2/creator/info` - Also show a list of creators that the user can select
  1. Note that this can search and return multiple creators. The V3 version only works for a single creator at a time.
1. Creator page
 1. `/api/v3/creator/info` - Get more details for the creator to display, including if livestreams are available
 1. `/api/v3/content/creator` - Show recent content by the creator
 1. `/api/v2/plan/info` - Show available plans the user can subscribe to for the creator
1. Content page
 1. `/api/v3/content/post` - Show more detailed information about a piece of content, including text description, available attachments, metadata, interactions, etc.
 1. `/api/v3/content/related` - List some related content for the user to watch next
 1. `/api/v3/comment` - Load comments for the content for the user to read
  1. There are several more comment APIs to post, like, dislike, etc.
 1. `/api/v2/user/ban/status` - Determine if the user is banned from this creator
 1. `/api/v3/content/{video|audio|picture|gallery}` - Load the attached media for the post. This is usually video, but audio, pictures, and galleries are also available.
 1. `/api/v2/cdn/delivery` - For video and audio, this is required to get the information to stream or download the content in media players
1. Livestream
 1. `/api/v2/cdn/delivery` - Using the type \"livestream\" to load the livestream media in a media player
 1. `wss://chat.floatplane.com/sails.io/?...` - To connect to the livestream chat over websocket. TODO: Map out the WebSocket API.
1. User Profile
 1. `/api/v3/user/self` - Display username, name, email, and profile pictures

## API Organization

The organization of APIs into categories in this document are reflected from the internal organization of the Floatplane website bundled code, from `frontend.floatplane.com/{version}/vendor.js`. This is in order to use the best organization from the original developers' point of view.

For instance, Floatplane's authentication endpoints are organized into `Auth.v2.login(...)`, `Auth.v2.logout()`, and `Auth.v3.getCaptchaInfo()`. A limitation in OpenAPI is the lack of nested tagging/structure, so this document splits `Auth` into `AuthV2` and `AuthV3` to emulate the nested structure.

## Notes

Note that the Floatplane API does support the use of [ETags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) for retrieving some information, such as retrieving information about creators, users, etc. Expect an HTTP 304 if the content has not changed, and to re-use cached responses. This is useful to ease the strain on Floatplane's API server.

The date-time format used by Floatplane API is not standard ISO 8601 format. The dates/times given by Floatplane include milliseconds. Depending on your code generator, you may need to override the date-time format to something similar to `yyyy-MM-dd'T'HH:mm:ss.SSSZ`, for both encoding and decoding.

## Overview
This API client was generated by the [OpenAPI Generator](https://openapi-generator.tech) project.  By using the [openapi-spec](https://github.com/OAI/OpenAPI-Specification) from a remote server, you can easily generate an API client.

- API version: 3.8.6
- Package version: 
- Build package: org.openapitools.codegen.languages.Swift5ClientCodegen

## Installation

Add the following entry in your Package.swift:

> .package(path: "./FloatplaneAPIClient")

## Documentation for API Endpoints

All URIs are relative to *https://www.floatplane.com*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*AuthV2API* | [**checkFor2faLogin**](docs/AuthV2API.md#checkfor2falogin) | **POST** /api/v2/auth/checkFor2faLogin | Check For 2FA Login
*AuthV2API* | [**login**](docs/AuthV2API.md#login) | **POST** /api/v2/auth/login | Login
*AuthV2API* | [**logout**](docs/AuthV2API.md#logout) | **POST** /api/v2/auth/logout | Logout
*AuthV3API* | [**getCaptchaInfo**](docs/AuthV3API.md#getcaptchainfo) | **GET** /api/v3/auth/captcha/info | Get Captcha Info
*CDNV2API* | [**getDeliveryInfo**](docs/CDNV2API.md#getdeliveryinfo) | **GET** /api/v2/cdn/delivery | Get Delivery Info
*CommentV3API* | [**dislikeComment**](docs/CommentV3API.md#dislikecomment) | **POST** /api/v3/comment/dislike | Dislike Comment
*CommentV3API* | [**getCommentReplies**](docs/CommentV3API.md#getcommentreplies) | **GET** /api/v3/comment/replies | Get Comment Replies
*CommentV3API* | [**getComments**](docs/CommentV3API.md#getcomments) | **GET** /api/v3/comment | Get Comments
*CommentV3API* | [**likeComment**](docs/CommentV3API.md#likecomment) | **POST** /api/v3/comment/like | Like Comment
*CommentV3API* | [**postComment**](docs/CommentV3API.md#postcomment) | **POST** /api/v3/comment | Post Comment
*ConnectedAccountsV2API* | [**listConnections**](docs/ConnectedAccountsV2API.md#listconnections) | **GET** /api/v2/connect/list | List Connections
*ContentV3API* | [**dislikeContent**](docs/ContentV3API.md#dislikecontent) | **POST** /api/v3/content/dislike | Dislike Content
*ContentV3API* | [**getBlogPost**](docs/ContentV3API.md#getblogpost) | **GET** /api/v3/content/post | Get Blog Post
*ContentV3API* | [**getContentTags**](docs/ContentV3API.md#getcontenttags) | **GET** /api/v3/content/tags | Get Content Tags
*ContentV3API* | [**getCreatorBlogPosts**](docs/ContentV3API.md#getcreatorblogposts) | **GET** /api/v3/content/creator | Get Creator Blog Posts
*ContentV3API* | [**getMultiCreatorBlogPosts**](docs/ContentV3API.md#getmulticreatorblogposts) | **GET** /api/v3/content/creator/list | Get Multi Creator Blog Posts
*ContentV3API* | [**getPictureContent**](docs/ContentV3API.md#getpicturecontent) | **GET** /api/v3/content/picture | Get Picture Content
*ContentV3API* | [**getRelatedBlogPosts**](docs/ContentV3API.md#getrelatedblogposts) | **GET** /api/v3/content/related | Get Related Blog Posts
*ContentV3API* | [**getVideoContent**](docs/ContentV3API.md#getvideocontent) | **GET** /api/v3/content/video | Get Video Content
*ContentV3API* | [**likeContent**](docs/ContentV3API.md#likecontent) | **POST** /api/v3/content/like | Like Content
*CreatorSubscriptionPlanV2API* | [**getCreatorSubInfoPublic**](docs/CreatorSubscriptionPlanV2API.md#getcreatorsubinfopublic) | **GET** /api/v2/plan/info | Get Creator Sub Info Public
*CreatorV2API* | [**getCreatorInfoByName**](docs/CreatorV2API.md#getcreatorinfobyname) | **GET** /api/v2/creator/named | Get Info By Name
*CreatorV2API* | [**getInfo**](docs/CreatorV2API.md#getinfo) | **GET** /api/v2/creator/info | Get Info
*CreatorV3API* | [**getCreator**](docs/CreatorV3API.md#getcreator) | **GET** /api/v3/creator/info | Get Creator
*CreatorV3API* | [**getCreators**](docs/CreatorV3API.md#getcreators) | **GET** /api/v3/creator/list | Get Creators
*FAQV2API* | [**getFaqSections**](docs/FAQV2API.md#getfaqsections) | **GET** /api/v2/faq/list | Get Faq Sections
*LoyaltyRewardsV3API* | [**listCreatorLoyaltyReward**](docs/LoyaltyRewardsV3API.md#listcreatorloyaltyreward) | **POST** /api/v3/user/loyaltyreward/list | List Creator Loyalty Reward
*PaymentsV2API* | [**listAddresses**](docs/PaymentsV2API.md#listaddresses) | **GET** /api/v2/payment/address/list | List Addresses
*PaymentsV2API* | [**listInvoices**](docs/PaymentsV2API.md#listinvoices) | **GET** /api/v2/payment/invoice/list | List Invoices
*PaymentsV2API* | [**listPaymentMethods**](docs/PaymentsV2API.md#listpaymentmethods) | **GET** /api/v2/payment/method/list | List Payment Methods
*SubscriptionsV3API* | [**listUserSubscriptionsV3**](docs/SubscriptionsV3API.md#listusersubscriptionsv3) | **GET** /api/v3/user/subscriptions | List User Subscriptions
*UserV2API* | [**getSecurity**](docs/UserV2API.md#getsecurity) | **GET** /api/v2/user/security | Get Security
*UserV2API* | [**getUserInfo**](docs/UserV2API.md#getuserinfo) | **GET** /api/v2/user/info | Info
*UserV2API* | [**getUserInfoByName**](docs/UserV2API.md#getuserinfobyname) | **GET** /api/v2/user/named | Get Info By Name
*UserV2API* | [**userCreatorBanStatus**](docs/UserV2API.md#usercreatorbanstatus) | **GET** /api/v2/user/ban/status | User Creator Ban Status
*UserV3API* | [**getActivityFeedV3**](docs/UserV3API.md#getactivityfeedv3) | **GET** /api/v3/user/activity | Get Activity Feed
*UserV3API* | [**getExternalLinksV3**](docs/UserV3API.md#getexternallinksv3) | **GET** /api/v3/user/links | Get External Links
*UserV3API* | [**getSelf**](docs/UserV3API.md#getself) | **GET** /api/v3/user/self | Get Self
*UserV3API* | [**getUserNotificationSettingsV3**](docs/UserV3API.md#getusernotificationsettingsv3) | **GET** /api/v3/user/notification/list | Get User Notification Settings
*UserV3API* | [**updateUserNotificationSettingsV3**](docs/UserV3API.md#updateusernotificationsettingsv3) | **POST** /api/v3/user/notification/update | Update User Notification Settings


## Documentation For Models

 - [AudioAttachmentModel](docs/AudioAttachmentModel.md)
 - [AudioAttachmentModelWaveform](docs/AudioAttachmentModelWaveform.md)
 - [AuthLoginV2Request](docs/AuthLoginV2Request.md)
 - [AuthLoginV2Response](docs/AuthLoginV2Response.md)
 - [BlogPostModelV3](docs/BlogPostModelV3.md)
 - [BlogPostModelV3Creator](docs/BlogPostModelV3Creator.md)
 - [BlogPostModelV3CreatorCategory](docs/BlogPostModelV3CreatorCategory.md)
 - [BlogPostModelV3CreatorOwner](docs/BlogPostModelV3CreatorOwner.md)
 - [CdnDeliveryV2Response](docs/CdnDeliveryV2Response.md)
 - [CdnDeliveryV2ResponseResource](docs/CdnDeliveryV2ResponseResource.md)
 - [CdnDeliveryV2ResponseResourceData](docs/CdnDeliveryV2ResponseResourceData.md)
 - [CdnDeliveryV2ResponseResourceDataQualityLevelParams](docs/CdnDeliveryV2ResponseResourceDataQualityLevelParams.md)
 - [CdnDeliveryV2ResponseResourceDataQualityLevels](docs/CdnDeliveryV2ResponseResourceDataQualityLevels.md)
 - [CheckFor2faLoginRequest](docs/CheckFor2faLoginRequest.md)
 - [ChildImageModel](docs/ChildImageModel.md)
 - [CommentLikeV3PostRequest](docs/CommentLikeV3PostRequest.md)
 - [CommentModel](docs/CommentModel.md)
 - [CommentModelInteractionCounts](docs/CommentModelInteractionCounts.md)
 - [CommentReplyModel](docs/CommentReplyModel.md)
 - [CommentV3PostRequest](docs/CommentV3PostRequest.md)
 - [CommentV3PostResponse](docs/CommentV3PostResponse.md)
 - [CommentV3PostResponseInteractionCounts](docs/CommentV3PostResponseInteractionCounts.md)
 - [ConnectedAccountModel](docs/ConnectedAccountModel.md)
 - [ConnectedAccountModelConnectedAccount](docs/ConnectedAccountModelConnectedAccount.md)
 - [ConnectedAccountModelConnectedAccountData](docs/ConnectedAccountModelConnectedAccountData.md)
 - [ContentCreatorListLastItems](docs/ContentCreatorListLastItems.md)
 - [ContentCreatorListV3Response](docs/ContentCreatorListV3Response.md)
 - [ContentLikeV3Request](docs/ContentLikeV3Request.md)
 - [ContentPictureV3Response](docs/ContentPictureV3Response.md)
 - [ContentPostV3Response](docs/ContentPostV3Response.md)
 - [ContentVideoV3Response](docs/ContentVideoV3Response.md)
 - [ContentVideoV3ResponseLevels](docs/ContentVideoV3ResponseLevels.md)
 - [CreatorModelV2](docs/CreatorModelV2.md)
 - [CreatorModelV3](docs/CreatorModelV3.md)
 - [CreatorModelV3Category](docs/CreatorModelV3Category.md)
 - [DiscordRoleModel](docs/DiscordRoleModel.md)
 - [DiscordServerModel](docs/DiscordServerModel.md)
 - [ErrorModel](docs/ErrorModel.md)
 - [ErrorModelErrors](docs/ErrorModelErrors.md)
 - [FaqSectionModel](docs/FaqSectionModel.md)
 - [FaqSectionModelFaqs](docs/FaqSectionModelFaqs.md)
 - [GetCaptchaInfoResponse](docs/GetCaptchaInfoResponse.md)
 - [GetCaptchaInfoResponseV2](docs/GetCaptchaInfoResponseV2.md)
 - [GetCaptchaInfoResponseV2Variants](docs/GetCaptchaInfoResponseV2Variants.md)
 - [GetCaptchaInfoResponseV2VariantsAndroid](docs/GetCaptchaInfoResponseV2VariantsAndroid.md)
 - [GetCaptchaInfoResponseV3](docs/GetCaptchaInfoResponseV3.md)
 - [GetCaptchaInfoResponseV3Variants](docs/GetCaptchaInfoResponseV3Variants.md)
 - [ImageModel](docs/ImageModel.md)
 - [LiveStreamModel](docs/LiveStreamModel.md)
 - [LiveStreamModelOffline](docs/LiveStreamModelOffline.md)
 - [PaymentAddressModel](docs/PaymentAddressModel.md)
 - [PaymentInvoiceListV2Response](docs/PaymentInvoiceListV2Response.md)
 - [PaymentInvoiceListV2ResponseInvoices](docs/PaymentInvoiceListV2ResponseInvoices.md)
 - [PaymentInvoiceListV2ResponsePlan](docs/PaymentInvoiceListV2ResponsePlan.md)
 - [PaymentInvoiceListV2ResponsePlanCreator](docs/PaymentInvoiceListV2ResponsePlanCreator.md)
 - [PaymentInvoiceListV2ResponseSubscriptions](docs/PaymentInvoiceListV2ResponseSubscriptions.md)
 - [PaymentMethodModel](docs/PaymentMethodModel.md)
 - [PaymentMethodModelCard](docs/PaymentMethodModelCard.md)
 - [PictureAttachmentModel](docs/PictureAttachmentModel.md)
 - [PlanInfoV2Response](docs/PlanInfoV2Response.md)
 - [PlanInfoV2ResponsePlans](docs/PlanInfoV2ResponsePlans.md)
 - [PostMetadataModel](docs/PostMetadataModel.md)
 - [SocialLinksModel](docs/SocialLinksModel.md)
 - [SubscriptionPlanModel](docs/SubscriptionPlanModel.md)
 - [UserActivityV3Response](docs/UserActivityV3Response.md)
 - [UserActivityV3ResponseActivity](docs/UserActivityV3ResponseActivity.md)
 - [UserInfoV2Response](docs/UserInfoV2Response.md)
 - [UserInfoV2ResponseUsers](docs/UserInfoV2ResponseUsers.md)
 - [UserModel](docs/UserModel.md)
 - [UserNamedV2Response](docs/UserNamedV2Response.md)
 - [UserNamedV2ResponseUsers](docs/UserNamedV2ResponseUsers.md)
 - [UserNotificationModel](docs/UserNotificationModel.md)
 - [UserNotificationModelUserNotificationSetting](docs/UserNotificationModelUserNotificationSetting.md)
 - [UserNotificationUpdateV3PostRequest](docs/UserNotificationUpdateV3PostRequest.md)
 - [UserSecurityV2Response](docs/UserSecurityV2Response.md)
 - [UserSelfModel](docs/UserSelfModel.md)
 - [UserSelfV3Response](docs/UserSelfV3Response.md)
 - [UserSubscriptionModel](docs/UserSubscriptionModel.md)
 - [UserSubscriptionModelPlan](docs/UserSubscriptionModelPlan.md)
 - [VideoAttachmentModel](docs/VideoAttachmentModel.md)


## Documentation For Authorization


## CookieAuth

- **Type**: API key
- **API key parameter name**: sails.sid
- **Location**: 


## Author



