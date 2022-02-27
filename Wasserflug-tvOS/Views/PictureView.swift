import SwiftUI
import AVKit
import FloatplaneAPIClient
import CachedAsyncImage

struct PictureView: View {
	
	@StateObject var viewModel: PictureViewModel
	
	var body: some View {
		switch viewModel.state {
		case .idle:
			ProgressView().onAppear(perform: {
				viewModel.load()
			})
		case .loading:
			ProgressView()
		case let .failed(error):
			ErrorView(error: error)
		case let .loaded(content):
			CachedAsyncImage(url: URL(string: content.imageFiles.first!.path), content: { image in
				image
					.resizable()
					.scaledToFit()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}, placeholder: {
				ProgressView()
			})
				.edgesIgnoringSafeArea(.all)
//				.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}

struct PictureView_Previews: PreviewProvider {
	static var previews: some View {
		PictureView(viewModel: PictureViewModel(fpApiService: MockFPAPIService(), pictureAttachment: MockData.getBlogPost.pictureAttachments[0]))
	}
}
