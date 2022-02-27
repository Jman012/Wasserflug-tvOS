# CommentV3API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dislikeComment**](CommentV3API.md#dislikecomment) | **POST** /api/v3/comment/dislike | Dislike Comment
[**getCommentReplies**](CommentV3API.md#getcommentreplies) | **GET** /api/v3/comment/replies | Get Comment Replies
[**getComments**](CommentV3API.md#getcomments) | **GET** /api/v3/comment | Get Comments
[**likeComment**](CommentV3API.md#likecomment) | **POST** /api/v3/comment/like | Like Comment
[**postComment**](CommentV3API.md#postcomment) | **POST** /api/v3/comment | Post Comment


# **dislikeComment**
```swift
    open class func dislikeComment(commentLikeV3PostRequest: CommentLikeV3PostRequest, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<DislikeComment>
```

Dislike Comment

Dislike a comment on a blog post.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let commentLikeV3PostRequest = CommentLikeV3PostRequest(comment: "comment_example", blogPost: "blogPost_example") // CommentLikeV3PostRequest | 

// Dislike Comment
CommentV3API.dislikeComment(commentLikeV3PostRequest: commentLikeV3PostRequest).whenComplete { result in
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
 **commentLikeV3PostRequest** | [**CommentLikeV3PostRequest**](CommentLikeV3PostRequest.md) |  | 

### Return type

#### DislikeComment

```swift
public enum DislikeComment {
    case http200(value: String?, raw: ClientResponse)
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
 - **Accept**: text/plain, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCommentReplies**
```swift
    open class func getCommentReplies(comment: String, blogPost: String, limit: Int, rid: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetCommentReplies>
```

Get Comment Replies

Retrieve more replies from a comment.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let comment = "comment_example" // String | The identifer of the comment from which to retrieve replies.
let blogPost = "blogPost_example" // String | The identifer of the blog post the `comment` belongs to.
let limit = 987 // Int | How many replies to retrieve.
let rid = "rid_example" // String | The identifer of the last reply in the reply chain.

// Get Comment Replies
CommentV3API.getCommentReplies(comment: comment, blogPost: blogPost, limit: limit, rid: rid).whenComplete { result in
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
 **comment** | **String** | The identifer of the comment from which to retrieve replies. | 
 **blogPost** | **String** | The identifer of the blog post the &#x60;comment&#x60; belongs to. | 
 **limit** | **Int** | How many replies to retrieve. | 
 **rid** | **String** | The identifer of the last reply in the reply chain. | 

### Return type

#### GetCommentReplies

```swift
public enum GetCommentReplies {
    case http200(value: [CommentReplyModel]?, raw: ClientResponse)
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

# **getComments**
```swift
    open class func getComments(blogPost: String, limit: Int, fetchAfter: String? = nil, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetComments>
```

Get Comments

Get comments for a blog post object. Note that replies to each comment tend to be limited to 3. The extra replies can be retrieved via `getCommentReplies`. The difference in `$response.body#/0/totalReplies` and `$response.body#/0/replies`'s length can determine if more comments need to be loaded.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let blogPost = "blogPost_example" // String | Which blog post to retrieve comments for.
let limit = 987 // Int | The maximum number of comments to return. This should be set to 20 by default.
let fetchAfter = "fetchAfter_example" // String | When loading more comments on a blog post, this is used to determine which which comments to skip. This is a GUID of the last comment from the previous call to `getComments`. (optional)

// Get Comments
CommentV3API.getComments(blogPost: blogPost, limit: limit, fetchAfter: fetchAfter).whenComplete { result in
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
 **blogPost** | **String** | Which blog post to retrieve comments for. | 
 **limit** | **Int** | The maximum number of comments to return. This should be set to 20 by default. | 
 **fetchAfter** | **String** | When loading more comments on a blog post, this is used to determine which which comments to skip. This is a GUID of the last comment from the previous call to &#x60;getComments&#x60;. | [optional] 

### Return type

#### GetComments

```swift
public enum GetComments {
    case http200(value: [CommentModel]?, raw: ClientResponse)
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

# **likeComment**
```swift
    open class func likeComment(commentLikeV3PostRequest: CommentLikeV3PostRequest, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<LikeComment>
```

Like Comment

Like a comment on a blog post.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let commentLikeV3PostRequest = CommentLikeV3PostRequest(comment: "comment_example", blogPost: "blogPost_example") // CommentLikeV3PostRequest | 

// Like Comment
CommentV3API.likeComment(commentLikeV3PostRequest: commentLikeV3PostRequest).whenComplete { result in
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
 **commentLikeV3PostRequest** | [**CommentLikeV3PostRequest**](CommentLikeV3PostRequest.md) |  | 

### Return type

#### LikeComment

```swift
public enum LikeComment {
    case http200(value: String?, raw: ClientResponse)
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
 - **Accept**: text/plain, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postComment**
```swift
    open class func postComment(commentV3PostRequest: CommentV3PostRequest, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<PostComment>
```

Post Comment

Post a new comment to a blog post object.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let commentV3PostRequest = CommentV3PostRequest(blogPost: "blogPost_example", text: "text_example") // CommentV3PostRequest | 

// Post Comment
CommentV3API.postComment(commentV3PostRequest: commentV3PostRequest).whenComplete { result in
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
 **commentV3PostRequest** | [**CommentV3PostRequest**](CommentV3PostRequest.md) |  | 

### Return type

#### PostComment

```swift
public enum PostComment {
    case http200(value: CommentV3PostResponse?, raw: ClientResponse)
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

