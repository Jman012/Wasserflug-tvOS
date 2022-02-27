# LoyaltyRewardsV3API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listCreatorLoyaltyReward**](LoyaltyRewardsV3API.md#listcreatorloyaltyreward) | **POST** /api/v3/user/loyaltyreward/list | List Creator Loyalty Reward


# **listCreatorLoyaltyReward**
```swift
    open class func listCreatorLoyaltyReward(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<ListCreatorLoyaltyReward>
```

List Creator Loyalty Reward

Retrieve a list of loyalty rewards for the user. The reason for why this is a POST and not a GET is unknown.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// List Creator Loyalty Reward
LoyaltyRewardsV3API.listCreatorLoyaltyReward().whenComplete { result in
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

#### ListCreatorLoyaltyReward

```swift
public enum ListCreatorLoyaltyReward {
    case http200(value: [AnyCodable]?, raw: ClientResponse)
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

