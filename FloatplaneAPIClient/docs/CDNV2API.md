# CDNV2API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDeliveryInfo**](CDNV2API.md#getdeliveryinfo) | **GET** /api/v2/cdn/delivery | Get Delivery Info


# **getDeliveryInfo**
```swift
    open class func getDeliveryInfo(type: ModelType_getDeliveryInfo, guid: String? = nil, creator: String? = nil, headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<GetDeliveryInfo>
```

Get Delivery Info

Given an video/audio attachment identifier, retrieves the information necessary to play, download, or livestream the video/audio at various quality levels.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient

let type = "type_example" // String | Used to determine which kind of retrieval method is requested for the video.  - VOD = stream a Video On Demand - AOD = stream Audio On Demand - Live = Livestream the content - Download = Download the content for the user to play later.
let guid = "guid_example" // String | The GUID of the attachment for a post, retrievable from the `videoAttachments` or `audioAttachments` object. Required when `type` is `vod`, `aod`, or `download`. Note: either this or `creator` must be supplied. (optional)
let creator = "creator_example" // String | The GUID of the creator for a livestream, retrievable from `CreatorModelV2.id`. Required when `type` is `live`. Note: either this or `guid` must be supplied. (optional)

// Get Delivery Info
CDNV2API.getDeliveryInfo(type: type, guid: guid, creator: creator).whenComplete { result in
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
 **type** | **String** | Used to determine which kind of retrieval method is requested for the video.  - VOD &#x3D; stream a Video On Demand - AOD &#x3D; stream Audio On Demand - Live &#x3D; Livestream the content - Download &#x3D; Download the content for the user to play later. | 
 **guid** | **String** | The GUID of the attachment for a post, retrievable from the &#x60;videoAttachments&#x60; or &#x60;audioAttachments&#x60; object. Required when &#x60;type&#x60; is &#x60;vod&#x60;, &#x60;aod&#x60;, or &#x60;download&#x60;. Note: either this or &#x60;creator&#x60; must be supplied. | [optional] 
 **creator** | **String** | The GUID of the creator for a livestream, retrievable from &#x60;CreatorModelV2.id&#x60;. Required when &#x60;type&#x60; is &#x60;live&#x60;. Note: either this or &#x60;guid&#x60; must be supplied. | [optional] 

### Return type

#### GetDeliveryInfo

```swift
public enum GetDeliveryInfo {
    case http200(value: CdnDeliveryV2Response?, raw: ClientResponse)
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

