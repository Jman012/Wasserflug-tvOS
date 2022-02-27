# CreatorV2API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCreatorInfoByName**](CreatorV2API.md#getcreatorinfobyname) | **GET** /api/v2/creator/named | Get Info By Name
[**getInfo**](CreatorV2API.md#getinfo) | **GET** /api/v2/creator/info | Get Info


# **getCreatorInfoByName**
```swift
    open class func getCreatorInfoByName(creatorURL: [String], headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetCreatorInfoByName>
```

Get Info By Name

Retrieve detailed information on one or more creators on Floatplane.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let creatorURL = ["inner_example"] // [String] | The string identifer(s) of the creator(s) to be retrieved.

// Get Info By Name
CreatorV2API.getCreatorInfoByName(creatorURL: creatorURL).whenComplete { result in
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
 **creatorURL** | [**[String]**](String.md) | The string identifer(s) of the creator(s) to be retrieved. | 

### Return type

#### GetCreatorInfoByName

```swift
public enum GetCreatorInfoByName {
    case http200(value: [CreatorModelV2]?, raw: ClientResponse)
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

# **getInfo**
```swift
    open class func getInfo(creatorGUID: [String], headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetInfo>
```

Get Info

Retrieve detailed information on one or more creators on Floatplane.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let creatorGUID = ["inner_example"] // [String] | The GUID identifer(s) of the creator(s) to be retrieved.

// Get Info
CreatorV2API.getInfo(creatorGUID: creatorGUID).whenComplete { result in
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
 **creatorGUID** | [**[String]**](String.md) | The GUID identifer(s) of the creator(s) to be retrieved. | 

### Return type

#### GetInfo

```swift
public enum GetInfo {
    case http200(value: [CreatorModelV2]?, raw: ClientResponse)
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

