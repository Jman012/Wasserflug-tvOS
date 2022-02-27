# ContentPostV3Response

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
**creator** | [**CreatorModelV2**](CreatorModelV2.md) |  | 
**wasReleasedSilently** | **Bool** |  | 
**thumbnail** | [**ImageModel**](ImageModel.md) |  | 
**isAccessible** | **Bool** |  | 
**userInteraction** | **[String]** |  | [optional] 
**videoAttachments** | [VideoAttachmentModel] |  | 
**audioAttachments** | [AnyCodable] |  | 
**pictureAttachments** | [PictureAttachmentModel] |  | 
**galleryAttachments** | [AnyCodable] |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


