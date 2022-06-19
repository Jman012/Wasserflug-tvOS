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
	@Namespace var likeDislikeCommentNamespace
	
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
					// The entire page is a VStack of rows of content in a scroll view
					VStack(alignment: .leading) {
						/* Top row */
						// Title
						Text(content.title)
							.font(.title3)
						
						// Tags under the title
						HStack(alignment: .top, spacing: 20) {
							ForEach(content.tags, id: \.self) { tag in
								Text("#" + tag)
									.foregroundColor(FPColors.blue)
									.font(.subheadline)
							}
						}
							.padding([.bottom])
						
						/* Thumbnail and description row */
						HStack(alignment: .top) {
							// Thumbnail with play button, on left of screen
							PlayMediaView(
								thumbnail: content.thumbnail,
								showPlayButton: !(content.videoAttachments?.isEmpty ?? false),
								width: geometry.size.width * 0.5,
								playButtonSize: .default,
								playContent: { beginningWatchTime in
									VStack {
										if let videoAttachments = content.videoAttachments, let firstVideo = videoAttachments.first {
											VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: firstVideo, contentPost: content, description: viewModel.textAttributedString), beginningWatchTime: beginningWatchTime)
										}
									}
								},
								defaultInNamespace: screenNamespace,
								isShowingMedia: shouldAutoPlay,
								watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", content.id, content.videoAttachments?.first?.id ?? ""), animation: .default))

							// Creator pfp, publish date, and description
							VStack(alignment: .leading) {
								HStack(alignment: .center, spacing: 20) {
									// Creator profile picture
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
										// Creator name
										Text(content.creator.title)
											.font(.headline)
										// Blog post publish date
										Text("\(content.releaseDate)")
											.font(.caption)
									}
									Spacer()
								}
								// The description. Pre-attributed from view model
								Text(viewModel.textAttributedString)
									.font(.body)
									.lineLimit(15)
									.padding([.top])
							}
								.frame(minWidth: geometry.size.width * 0.5)
						}
							.focusSection()
						
						// Like/dislike/comments row
						ZStack(alignment: .leading) {
							Rectangle()
								.fill(.clear)
							HStack {
								// Like button
								Button(action: {
									viewModel.like()
								}) {
									Image(systemName: viewModel.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
									let additional = viewModel.isLiked && viewModel.latestUserInteraction != nil ? 1 : 0
									Text("\(content.likes + additional)")
								}
									.prefersDefaultFocus(in: likeDislikeCommentNamespace)
									.foregroundColor(viewModel.isLiked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)
								
								// Dislike button
								Button(action: {
									viewModel.dislike()
								}) {
									Image(systemName: viewModel.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
									let additional = viewModel.isDisliked && viewModel.latestUserInteraction != nil ? 1 : 0
									Text("\(content.dislikes + additional)")
								}
									.foregroundColor(viewModel.isDisliked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)
								
								// Comments label
								Text("\(content.comments) comment\(content.comments == 1 ? "" : "s")")
							}
								.padding()
						}
							.frame(maxWidth: .infinity)
							.focusSection()
							.focusScope(likeDislikeCommentNamespace)
						
						// If applicable, show all attachments as the last rows
						if !(content.videoAttachments?.count == 1 && content.pictureAttachments?.isEmpty ?? true && content.audioAttachments?.isEmpty ?? true && content.galleryAttachments?.isEmpty ?? true) {
							BlogPostContentView(geometry: geometry, content: content, fpApiService: fpApiService, description: viewModel.textAttributedString)
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
