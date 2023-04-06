import SwiftUI
import AVKit
import FloatplaneAPIClient

struct VideoView: View {
	
	@StateObject var viewModel: VideoViewModel
	
	var body: some View {
		switch viewModel.state {
		case .idle:
			ProgressView().onAppear(perform: {
				viewModel.load()
			})
		case .loading:
			ProgressView()
		case let .failed(error):
			ErrorView(error: error, tryAgainText: "Refresh", tryAgainHandler: {
				viewModel.state = .idle
			})
		case let .loaded((_, videoContent)):
			VideoPlayerView(viewModel: viewModel, videoContent: videoContent)
				.edgesIgnoringSafeArea(.all)
		}
	}
}

struct VideoView_Previews: PreviewProvider {
	static var previews: some View {
		VideoView(viewModel: VideoViewModel(fpApiService: MockFPAPIService(), videoAttachment: MockData.getBlogPost.videoAttachments!.first!, contentPost: MockData.getBlogPost, description: "Test description"))
	}
}
