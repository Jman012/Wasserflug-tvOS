import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostView: View {
	@StateObject var viewModel: BlogPostViewModel
	var shouldAutoPlay: Bool
	
	@Environment(\.resetFocus) var resetFocus
	@Environment(\.fpApiService) var fpApiService
	@Environment(\.colorScheme) var colorScheme
	@Namespace var screenNamespace
	
	@State var isShowingVideo = false
	
	var body: some View {
		switch viewModel.state {
		case .idle:
			ProgressView().onAppear(perform: {
				viewModel.load(colorScheme: colorScheme)
			})
		case .loading:
			ProgressView()
		case let .failed(error):
			ErrorView(error: error)
		case let .loaded(content):
			GeometryReader { geometry in
				ScrollView {
					VStack(alignment: .leading) {
						Text(content.title)
							.font(.title3)
						HStack(alignment: .top, spacing: 20) {
							ForEach(content.tags, id: \.self) { tag in
								Text("#" + tag)
									.foregroundColor(FPColors.blue)
									.font(.subheadline)
							}
						}
							.padding([.bottom])
						HStack(alignment: .top) {
							PlayMediaView(
								thumbnail: content.thumbnail,
								showPlayButton: !content.videoAttachments.isEmpty,
								width: geometry.size.width * 0.5,
								playButtonSize: .default,
								playContent: {
									VStack {
										if let firstVideo = content.videoAttachments.first {
											VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: firstVideo, contentPost: content))
										}
									}
								},
								isShowingMedia: shouldAutoPlay)

							VStack(alignment: .leading) {
								HStack(alignment: .center, spacing: 20) {
									CachedAsyncImage(url: URL(string: content.creator.icon.path), content: { image in
										image
											.resizable()
											.frame(width: 75, height: 75)
											.clipShape(Circle())
									}, placeholder: {
										ProgressView()
											.frame(width: 75, height: 75)
									})
									VStack(alignment: .leading) {
										Text(content.creator.title)
											.font(.headline)
										Text("\(content.releaseDate)")
											.font(.caption)

									}
									Spacer()
								}
								Text(viewModel.textAttributedString)
									.font(.body)
									.lineLimit(15)
									.padding([.top])
							}
								.frame(minWidth: geometry.size.width * 0.5)
						}
							.focusSection()
						ZStack(alignment: .leading) {
							Rectangle()
								.fill(.clear)
							HStack {
								Button(action: {
									viewModel.like()
								}) {
									Image(systemName: viewModel.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
									let additional = viewModel.isLiked && viewModel.latestUserInteraction != nil ? 1 : 0
									Text("\(content.likes + additional)")
								}
								.foregroundColor(viewModel.isLiked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)
								Button(action: {
									viewModel.dislike()
								}) {
									Image(systemName: viewModel.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
									let additional = viewModel.isDisliked && viewModel.latestUserInteraction != nil ? 1 : 0
									Text("\(content.dislikes + additional)")
								}
									.foregroundColor(viewModel.isDisliked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)
								Text("\(content.comments) comment\(content.comments == 1 ? "" : "s")")
							}
							.padding()
						}
							.frame(maxWidth: .infinity)
							.focusSection()
						if !(content.videoAttachments.count == 1 && content.pictureAttachments.count == 0 && content.audioAttachments.count == 0 && content.galleryAttachments.count == 0) {
							BlogPostContentView(geometry: geometry, content: content, fpApiService: fpApiService)
						}
					}
					
				}
			}
				.focusScope(screenNamespace)
		}
	}
}

struct BlogPostView_Previews: PreviewProvider {
	static var previews: some View {
		BlogPostView(viewModel: BlogPostViewModel(fpApiService: MockFPAPIService(), id: ""), shouldAutoPlay: false)
	}
}
