# CreatorSubscriptionPlanV2API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCreatorSubInfoPublic**](CreatorSubscriptionPlanV2API.md#getcreatorsubinfopublic) | **GET** /api/v2/plan/info | Get Creator Sub Info Public


# **getCreatorSubInfoPublic**
```swift
    open class func getCreatorSubInfoPublic(creatorId: String, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetCreatorSubInfoPublic>
```

Get Creator Sub Info Public

Retrieve detailed information about a creator's subscription plans and their subscriber count.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let creatorId = "creatorId_example" // String | The GUID for the creator being search.

// Get Creator Sub Info Public
CreatorSubscriptionPlanV2API.getCreatorSubInfoPublic(creatorId: creatorId).whenComplete { result in
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
 **creatorId** | **String** | The GUID for the creator being search. | 

### Return type

#### GetCreatorSubInfoPublic

```swift
public enum GetCreatorSubInfoPublic {
    case http200(value: PlanInfoV2Response?, raw: ClientResponse)
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

