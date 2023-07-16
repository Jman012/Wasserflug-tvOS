import Foundation
import FloatplaneAPIClient
import NIO

class PictureViewModel: BaseViewModel, ObservableObject {
	@Published var state: ViewModelState<ContentPictureV3Response> = .idle
	
	private let fpApiService: FPAPIService
	let pictureAttachment: PictureAttachmentModel
	
	init(fpApiService: FPAPIService, pictureAttachment: PictureAttachmentModel) {
		self.fpApiService = fpApiService
		self.pictureAttachment = pictureAttachment
	}
	
	func load() {
		state = .loading
		
		logger.info("Loading picture information.", metadata: [
			"id": "\(pictureAttachment.guid)",
		])
		
		fpApiService
			.getPictureContent(id: pictureAttachment.guid)
			.flatMapResult { response -> Result<ContentPictureV3Response, Error> in
				switch response {
				case let .http200(value: pictureAttachment, clientResponse):
					self.logger.debug("Picture information raw response: \(clientResponse.plaintextDebugContent)")
					return .success(pictureAttachment)
				case let .http0(value: errorModel, clientResponse),
					 let .http400(value: errorModel, clientResponse),
					 let .http401(value: errorModel, clientResponse),
					 let .http403(value: errorModel, clientResponse),
					 let .http404(value: errorModel, clientResponse):
					self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading picture information. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
					return .failure(errorModel)
				case .http429(raw: _):
					self.logger.warning("Received HTTP 429 Too Many Requests.")
					return .failure(WasserflugError.http429)
				}
			}
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(response):
						self.logger.notice("Received picture information.", metadata: [
							"url": "\(String(describing: response.imageFiles))",
						])
						self.state = .loaded(response)
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading picture information. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.state = .failed(error)
					}
				}
			}
	}
}
