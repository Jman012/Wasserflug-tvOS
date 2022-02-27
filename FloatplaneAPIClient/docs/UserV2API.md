# UserV2API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSecurity**](UserV2API.md#getsecurity) | **GET** /api/v2/user/security | Get Security
[**getUserInfo**](UserV2API.md#getuserinfo) | **GET** /api/v2/user/info | Info
[**getUserInfoByName**](UserV2API.md#getuserinfobyname) | **GET** /api/v2/user/named | Get Info By Name
[**userCreatorBanStatus**](UserV2API.md#usercreatorbanstatus) | **GET** /api/v2/user/ban/status | User Creator Ban Status


# **getSecurity**
```swift
    open class func getSecurity(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetSecurity>
```

Get Security

Retrieve information about the current security configuration for the user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// Get Security
UserV2API.getSecurity().whenComplete { result in
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

#### GetSecurity

```swift
public enum GetSecurity {
    case http200(value: UserSecurityV2Response?, raw: ClientResponse)
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

# **getUserInfo**
```swift
    open class func getUserInfo(id: [String], headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetUserInfo>
```

Info

Retrieve more detailed information about one or more users from their identifiers.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let id = ["inner_example"] // [String] | The GUID identifer(s) of the user(s) to be retrieved.

// Info
UserV2API.getUserInfo(id: id).whenComplete { result in
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
 **id** | [**[String]**](String.md) | The GUID identifer(s) of the user(s) to be retrieved. | 

### Return type

#### GetUserInfo

```swift
public enum GetUserInfo {
    case http200(value: UserInfoV2Response?, raw: ClientResponse)
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

# **getUserInfoByName**
```swift
    open class func getUserInfoByName(username: [String], headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetUserInfoByName>
```

Get Info By Name

Retrieve more detailed information about one or more users from their usernames.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let username = ["inner_example"] // [String] | The username(s) of the user(s) to be retrieved.

// Get Info By Name
UserV2API.getUserInfoByName(username: username).whenComplete { result in
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
 **username** | [**[String]**](String.md) | The username(s) of the user(s) to be retrieved. | 

### Return type

#### GetUserInfoByName

```swift
public enum GetUserInfoByName {
    case http200(value: UserNamedV2Response?, raw: ClientResponse)
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

# **userCreatorBanStatus**
```swift
    open class func userCreatorBanStatus(creator: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<UserCreatorBanStatus>
```

User Creator Ban Status

Determine whether or not the user is banned for a given creator.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let creator = "creator_example" // String | The GUID of the creator being queried.

// User Creator Ban Status
UserV2API.userCreatorBanStatus(creator: creator).whenComplete { result in
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
 **creator** | **String** | The GUID of the creator being queried. | 

### Return type

#### UserCreatorBanStatus

```swift
public enum UserCreatorBanStatus {
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

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

