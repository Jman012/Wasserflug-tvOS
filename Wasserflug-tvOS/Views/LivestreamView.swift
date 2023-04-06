import SwiftUI
import CachedAsyncImage

struct LivestreamView: View {
	@Environment(\.scenePhase) var scenePhase
	@StateObject var viewModel: LivestreamViewModel
	
	var body: some View {
		VStack {
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
			case let .loaded((creator, _, _)):
				if !viewModel.isLive {
					VStack {
						CachedAsyncImage(url: URL(string: creator.liveStream?.thumbnail?.path ?? ""), content: { image in
							image
								.resizable()
								.scaledToFit()
						}, placeholder: {
							ProgressView()
						})

						Text(creator.liveStream?.offline.title ?? "")
							.font(.title2)
						Text(creator.liveStream?.offline.description ?? "")
					}
				} else {
					LivestreamPlayerView(viewModel: viewModel)
						.ignoresSafeArea()
				}
			}
		}
		.onAppear {
			viewModel.startLoadingLiveStatus()
		}.onDisappear {
			viewModel.stopLoadingLiveStatus()
		}.onChange(of: scenePhase, perform: { phase in
			switch phase {
			case .active:
				viewModel.loadLiveStatus()
			case .inactive, .background:
				viewModel.stopLoadingLiveStatus()
			@unknown default:
				break
			}
		})
	}
}

struct LivestreamView_Previews: PreviewProvider {
	static var previews: some View {
		LivestreamView(viewModel: LivestreamViewModel(
			fpApiService: MockFPAPIService(),
			creatorId: MockData.creators[0].id))
	}
}
