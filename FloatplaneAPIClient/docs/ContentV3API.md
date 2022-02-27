# ContentV3API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dislikeContent**](ContentV3API.md#dislikecontent) | **POST** /api/v3/content/dislike | Dislike Content
[**getBlogPost**](ContentV3API.md#getblogpost) | **GET** /api/v3/content/post | Get Blog Post
[**getCreatorBlogPosts**](ContentV3API.md#getcreatorblogposts) | **GET** /api/v3/content/creator | Get Creator Blog Posts
[**getMultiCreatorBlogPosts**](ContentV3API.md#getmulticreatorblogposts) | **GET** /api/v3/content/creator/list | Get Multi Creator Blog Posts
[**getPictureContent**](ContentV3API.md#getpicturecontent) | **GET** /api/v3/content/picture | Get Picture Content
[**getRelatedBlogPosts**](ContentV3API.md#getrelatedblogposts) | **GET** /api/v3/content/related | Get Related Blog Posts
[**getVideoContent**](ContentV3API.md#getvideocontent) | **GET** /api/v3/content/video | Get Video Content
[**likeContent**](ContentV3API.md#likecontent) | **POST** /api/v3/content/like | Like Content


# **dislikeContent**
```swift
    open class func dislikeContent(contentLikeV3Request: ContentLikeV3Request, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<DislikeContent>
```

Dislike Content

Toggles the dislike status on a piece of content. If liked before, it will turn into a dislike. If disliked before, the dislike will be removed.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let contentLikeV3Request = ContentLikeV3Request(contentType: "contentType_example", id: "id_example") // ContentLikeV3Request | 

// Dislike Content
ContentV3API.dislikeContent(contentLikeV3Request: contentLikeV3Request).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **contentLikeV3Request** | [**ContentLikeV3Request**](ContentLikeV3Request.md) |  | 

### Return type

#### DislikeContent

```swift
public enum DislikeContent {
    case http200(value: [String]?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBlogPost**
```swift
    open class func getBlogPost(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetBlogPost>
```

Get Blog Post

Retrieve more details on a specific blog post object for viewing.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The ID of the post to be retrieved.

// Get Blog Post
ContentV3API.getBlogPost(id: id).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** | The ID of the post to be retrieved. | 

### Return type

#### GetBlogPost

```swift
public enum GetBlogPost {
    case http200(value: ContentPostV3Response?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCreatorBlogPosts**
```swift
    open class func getCreatorBlogPosts(id: String, limit: Int, fetchAfter: Int? = nil, search: String? = nil, tags: [String]? = nil, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetCreatorBlogPosts>
```

Get Creator Blog Posts

Retrieve a paginated list of blog posts from a creator. Or search for blog posts from a creator.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The GUID of the creator to retrieve posts from.
let limit = 987 // Int | The maximum number of posts to return.
let fetchAfter = 987 // Int | The number of posts to skip. Usually a multiple of `limit`, to get the next \"page\" of results. (optional)
let search = "search_example" // String | Search filter to look for specific posts. (optional)
let tags = ["inner_example"] // [String] | An array of tags to search against, possibly in addition to `search`. (optional)

// Get Creator Blog Posts
ContentV3API.getCreatorBlogPosts(id: id, limit: limit, fetchAfter: fetchAfter, search: search, tags: tags).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** | The GUID of the creator to retrieve posts from. | 
 **limit** | **Int** | The maximum number of posts to return. | 
 **fetchAfter** | **Int** | The number of posts to skip. Usually a multiple of &#x60;limit&#x60;, to get the next \&quot;page\&quot; of results. | [optional] 
 **search** | **String** | Search filter to look for specific posts. | [optional] 
 **tags** | [**[String]**](String.md) | An array of tags to search against, possibly in addition to &#x60;search&#x60;. | [optional] 

### Return type

#### GetCreatorBlogPosts

```swift
public enum GetCreatorBlogPosts {
    case http200(value: [BlogPostModelV3]?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMultiCreatorBlogPosts**
```swift
    open class func getMultiCreatorBlogPosts(ids: [String], limit: Int, fetchAfter: [ContentCreatorListLastItems]? = nil, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetMultiCreatorBlogPosts>
```

Get Multi Creator Blog Posts

Retrieve paginated blog posts from multiple creators for the home page.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let ids = ["inner_example"] // [String] | The GUID(s) of the creator(s) to retrieve posts from.
let limit = 987 // Int | The maximum number of posts to retrieve.
let fetchAfter = [ContentCreatorListLastItems(creatorId: "creatorId_example", blogPostId: "blogPostId_example", moreFetchable: false)] // [ContentCreatorListLastItems] | For pagination, this is used to determine which posts to skip. There should be one `fetchAfter` object for each creator in `ids`. The `moreFetchable` in the request, and all of the data, comes from the `ContentCreatorListV3Response`. (optional)

// Get Multi Creator Blog Posts
ContentV3API.getMultiCreatorBlogPosts(ids: ids, limit: limit, fetchAfter: fetchAfter).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ids** | [**[String]**](String.md) | The GUID(s) of the creator(s) to retrieve posts from. | 
 **limit** | **Int** | The maximum number of posts to retrieve. | 
 **fetchAfter** | [**[ContentCreatorListLastItems]**](ContentCreatorListLastItems.md) | For pagination, this is used to determine which posts to skip. There should be one &#x60;fetchAfter&#x60; object for each creator in &#x60;ids&#x60;. The &#x60;moreFetchable&#x60; in the request, and all of the data, comes from the &#x60;ContentCreatorListV3Response&#x60;. | [optional] 

### Return type

#### GetMultiCreatorBlogPosts

```swift
public enum GetMultiCreatorBlogPosts {
    case http200(value: ContentCreatorListV3Response?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPictureContent**
```swift
    open class func getPictureContent(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetPictureContent>
```

Get Picture Content

Retrieve more information on a picture attachment from a blog post in order to consume the picture content.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The ID of the picture attachment object, from the `BlogPostModelV3`.

// Get Picture Content
ContentV3API.getPictureContent(id: id).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** | The ID of the picture attachment object, from the &#x60;BlogPostModelV3&#x60;. | 

### Return type

#### GetPictureContent

```swift
public enum GetPictureContent {
    case http200(value: ContentPictureV3Response?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRelatedBlogPosts**
```swift
    open class func getRelatedBlogPosts(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetRelatedBlogPosts>
```

Get Related Blog Posts

Retrieve a list of blog posts that are related to the post being viewed.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The ID of the originating post.

// Get Related Blog Posts
ContentV3API.getRelatedBlogPosts(id: id).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** | The ID of the originating post. | 

### Return type

#### GetRelatedBlogPosts

```swift
public enum GetRelatedBlogPosts {
    case http200(value: [BlogPostModelV3]?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVideoContent**
```swift
    open class func getVideoContent(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetVideoContent>
```

Get Video Content

Retrieve more information on a video attachment from a blog post in order to consume the video content.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The ID of the video attachment object, from the `BlogPostModelV3`.

// Get Video Content
ContentV3API.getVideoContent(id: id).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String** | The ID of the video attachment object, from the &#x60;BlogPostModelV3&#x60;. | 

### Return type

#### GetVideoContent

```swift
public enum GetVideoContent {
    case http200(value: ContentVideoV3Response?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **likeContent**
```swift
    open class func likeContent(contentLikeV3Request: ContentLikeV3Request, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<LikeContent>
```

Like Content

Toggles the like status on a piece of content. If disliked before, it will turn into a like. If liked before, the like will be removed.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let contentLikeV3Request = ContentLikeV3Request(contentType: "contentType_example", id: "id_example") // ContentLikeV3Request | 

// Like Content
ContentV3API.likeContent(contentLikeV3Request: contentLikeV3Request).whenComplete { result in
    switch result {
    case .failure(let error):
    // process error
    case .success(let response):
        switch response {
        // process decoded response value or raw ClientResponse
        case .http200(let value, let raw):
        case .http400(let value, let raw):
        case .http401(let value, let raw):
        case .http403(let value, let raw):
        case .http404(let value, let raw):
        case .http0(let value, let raw):
        }
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **contentLikeV3Request** | [**ContentLikeV3Request**](ContentLikeV3Request.md) |  | 

### Return type

#### LikeContent

```swift
public enum LikeContent {
    case http200(value: [String]?, raw: ClientResponse)
    case http400(value: ErrorModel?, raw: ClientResponse)
    case http401(value: ErrorModel?, raw: ClientResponse)
    case http403(value: ErrorModel?, raw: ClientResponse)
    case http404(value: ErrorModel?, raw: ClientResponse)
    case http0(value: ErrorModel?, raw: ClientResponse)
}
```

### Authorization

[CookieAuth](../README.md#CookieAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

