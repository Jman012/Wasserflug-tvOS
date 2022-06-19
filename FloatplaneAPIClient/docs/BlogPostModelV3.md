# BlogPostModelV3

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**guid** | **String** |  | 
**title** | **String** |  | 
**text** | **String** | Text description of the post. May have HTML paragraph (&#x60;&lt;p&gt;&#x60;) tags surrounding it, along with other HTML.. | 
**type** | **String** |  | 
**tags** | **[String]** |  | 
**attachmentOrder** | **[String]** |  | 
**metadata** | [**PostMetadataModel**](PostMetadataModel.md) |  | 
**releaseDate** | **Date** |  | 
**likes** | **Int** |  | 
**dislikes** | **Int** |  | 
**score** | **Int** |  | 
**comments** | **Int** |  | 
**creator** | [**BlogPostModelV3Creator**](BlogPostModelV3Creator.md) |  | 
**wasReleasedSilently** | **Bool** |  | 
**thumbnail** | [**ImageModel**](ImageModel.md) |  | [optional] 
**isAccessible** | **Bool** | If false, the post should be marked as locked and not viewable by the user. | 
**videoAttachments** | **[String]** |  | [optional] 
**audioAttachments** | **[String]** |  | [optional] 
**pictureAttachments** | **[String]** |  | [optional] 
**galleryAttachments** | **[String]** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


