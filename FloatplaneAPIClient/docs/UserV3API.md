# UserV3API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getActivityFeedV3**](UserV3API.md#getactivityfeedv3) | **GET** /api/v3/user/activity | Get Activity Feed
[**getExternalLinksV3**](UserV3API.md#getexternallinksv3) | **GET** /api/v3/user/links | Get External Links
[**getSelf**](UserV3API.md#getself) | **GET** /api/v3/user/self | Get Self
[**getUserNotificationSettingsV3**](UserV3API.md#getusernotificationsettingsv3) | **GET** /api/v3/user/notification/list | Get User Notification Settings
[**updateUserNotificationSettingsV3**](UserV3API.md#updateusernotificationsettingsv3) | **POST** /api/v3/user/notification/update | Update User Notification Settings


# **getActivityFeedV3**
```swift
    open class func getActivityFeedV3(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetActivityFeedV3>
```

Get Activity Feed

Retrieve recent activity for a user, such as comments and other interactions they have made on posts for creators.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The GUID of the user being queried.

// Get Activity Feed
UserV3API.getActivityFeedV3(id: id).whenComplete { result in
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
 **id** | **String** | The GUID of the user being queried. | 

### Return type

#### GetActivityFeedV3

```swift
public enum GetActivityFeedV3 {
    case http200(value: UserActivityV3Response?, raw: ClientResponse)
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

# **getExternalLinksV3**
```swift
    open class func getExternalLinksV3(id: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetExternalLinksV3>
```

Get External Links

Retrieve configured social media links from a user's profile.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = "id_example" // String | The GUID of the user being searched.

// Get External Links
UserV3API.getExternalLinksV3(id: id).whenComplete { result in
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
 **id** | **String** | The GUID of the user being searched. | 

### Return type

#### GetExternalLinksV3

```swift
public enum GetExternalLinksV3 {
    case http200(value: [String: AnyCodable]?, raw: ClientResponse)
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

# **getSelf**
```swift
    open class func getSelf(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetSelf>
```

Get Self

Retrieve more detailed information about the user, including their name and email.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// Get Self
UserV3API.getSelf().whenComplete { result in
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
This endpoint does not need any parameter.

### Return type

#### GetSelf

```swift
public enum GetSelf {
    case http200(value: UserSelfV3Response?, raw: ClientResponse)
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

# **getUserNotificationSettingsV3**
```swift
    open class func getUserNotificationSettingsV3(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetUserNotificationSettingsV3>
```

Get User Notification Settings

Retrieve notification details for a user. The details are split into seperate settings for each subscribed creator.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// Get User Notification Settings
UserV3API.getUserNotificationSettingsV3().whenComplete { result in
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
This endpoint does not need any parameter.

### Return type

#### GetUserNotificationSettingsV3

```swift
public enum GetUserNotificationSettingsV3 {
    case http200(value: [UserNotificationModel]?, raw: ClientResponse)
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

# **updateUserNotificationSettingsV3**
```swift
    open class func updateUserNotificationSettingsV3(userNotificationUpdateV3PostRequest: UserNotificationUpdateV3PostRequest, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<UpdateUserNotificationSettingsV3>
```

Update User Notification Settings

Enable or disable email or push notifications for a specific creator.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let userNotificationUpdateV3PostRequest = UserNotificationUpdateV3PostRequest(creator: "creator_example", property: "property_example", newValue: false) // UserNotificationUpdateV3PostRequest | 

// Update User Notification Settings
UserV3API.updateUserNotificationSettingsV3(userNotificationUpdateV3PostRequest: userNotificationUpdateV3PostRequest).whenComplete { result in
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
 **userNotificationUpdateV3PostRequest** | [**UserNotificationUpdateV3PostRequest**](UserNotificationUpdateV3PostRequest.md) |  | 

### Return type

#### UpdateUserNotificationSettingsV3

```swift
public enum UpdateUserNotificationSettingsV3 {
    case http200(value: Bool?, raw: ClientResponse)
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

