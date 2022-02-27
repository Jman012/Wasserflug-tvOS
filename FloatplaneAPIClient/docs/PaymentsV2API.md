# PaymentsV2API

All URIs are relative to *https://www.floatplane.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listAddresses**](PaymentsV2API.md#listaddresses) | **GET** /api/v2/payment/address/list | List Addresses
[**listInvoices**](PaymentsV2API.md#listinvoices) | **GET** /api/v2/payment/invoice/list | List Invoices
[**listPaymentMethods**](PaymentsV2API.md#listpaymentmethods) | **GET** /api/v2/payment/method/list | List Payment Methods


# **listAddresses**
```swift
    open class func listAddresses(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<ListAddresses>
```

List Addresses

Retrieve a list of billing addresses saved to the user's account, to be used in conjunction with a payment method when purchasing subscriptions to creators.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// List Addresses
PaymentsV2API.listAddresses().whenComplete { result in
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

#### ListAddresses

```swift
public enum ListAddresses {
    case http200(value: [PaymentAddressModel]?, raw: ClientResponse)
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

# **listInvoices**
```swift
    open class func listInvoices(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<ListInvoices>
```

List Invoices

Retrieve a list of paid or unpaid subscription invoices for the user.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// List Invoices
PaymentsV2API.listInvoices().whenComplete { result in
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

#### ListInvoices

```swift
public enum ListInvoices {
    case http200(value: PaymentInvoiceListV2Response?, raw: ClientResponse)
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

# **listPaymentMethods**
```swift
    open class func listPaymentMethods(headers: HTTPHeaders = FloatplaneAPIClientAPI.customHeaders, beforeSend: (inout ClientRequest) throws -> () = { _ in }) -> EventLoopFuture<ListPaymentMethods>
```

List Payment Methods

Retrieve a list of saved payment methods for the user's account. Payment methods are how the user can pay for their subscription to creators on the platform.

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import FloatplaneAPIClient


// List Payment Methods
PaymentsV2API.listPaymentMethods().whenComplete { result in
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

#### ListPaymentMethods

```swift
public enum ListPaymentMethods {
    case http200(value: [PaymentMethodModel]?, raw: ClientResponse)
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

