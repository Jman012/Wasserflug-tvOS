import SwiftUI
import FloatplaneAPIClient

struct BlogPostView: View {
	@StateObject var viewModel: BlogPostViewModel
	var shouldAutoPlay: Bool
	
	@Environment(\.resetFocus) var resetFocus
	@Environment(\.fpApiService) var fpApiService
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var navCoordinator: NavigationCoordinator<WasserflugRoute>
	@Namespace var screenNamespace
		
	var body: some View {
		switch viewModel.state {
		case .idle:
			ProgressView()
				.onAppear(perform: {
					viewModel.load(colorScheme: colorScheme)
				})
		case .loading:
			ProgressView()
		case let .failed(error):
			ErrorView(error: error, tryAgainText: "Refresh", tryAgainHandler: {
				viewModel.state = .idle
			})
		case let .loaded(content):
			GeometryReader { geometry in
				ScrollView {
					// The entire page is a VStack of rows of content in a scroll view
					VStack(alignment: .leading) {
						/* Top row */
						// Title
						Text(content.title)
							.font(.title3)
							.accessibilityAddTraits(.isHeader)
						
						// Tags under the title
						if !content.tags.isEmpty {
							HStack(alignment: .top, spacing: 20) {
								ForEach(content.tags, id: \.self) { tag in
									Text("#" + tag)
										.foregroundColor(FPColors.blue)
										.font(.subheadline)
										.accessibilityLabel(tag)
								}
							}
							.padding([.bottom])
							.accessibilityElement(children: .ignore)
							.accessibilityLabel("Tags")
							.accessibilityValue(String(content.tags.joined(by: ", ")))
						}
						
						/* Thumbnail and description row */
						HStack(alignment: .top, spacing: 40) {
							// Thumbnail with play button, on left of screen
							if let thumbnail = content.thumbnail {
								PlayMediaView(
									thumbnail: content.thumbnail,
									viewMode: content.videoAttachments?.isEmpty == false ? .playButton : .imageCard,
									playButtonSize: .default,
									videoTitle: content.firstVideoAttachment?.title ?? "",
									playContent: { beginningWatchTime in
										DispatchQueue.main.async {
											if let firstVideo = content.firstVideoAttachment {
												navCoordinator.push(route: .videoView(videoAttachment: firstVideo, content: content, description: viewModel.textAttributedString, beginningWatchTime: beginningWatchTime))
											}
										}
									},
									autoPlay: shouldAutoPlay,
									watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", content.id, content.firstVideoAttachmentId ?? ""), animation: .default)
								)
								.accessibilityIdentifier("Thumbnail and play button")
								.prefersDefaultFocus(in: screenNamespace)
							}

							// Creator pfp, publish date, and description
							VStack(alignment: .leading) {
								HStack(alignment: .center, spacing: 20) {
									// Creator profile picture
									AsyncImage(url: URL(string: content.creator.icon.path), content: { image in
										image
											.resizable()
											.frame(width: 75, height: 75)
											.clipShape(Circle())
									}, placeholder: {
										ProgressView()
											.frame(width: 75, height: 75)
									})
									.accessibilityHidden(true)
									
									VStack(alignment: .leading) {
										// Creator name
										Text(content.channel.title)
											.font(.headline)
											.accessibilityIdentifier("Channel")
										// Blog post publish date
										Text("\(content.releaseDate)")
											.font(.caption)
											.accessibilityIdentifier("Release date")
									}
									Spacer()
								}
								// The description. Pre-attributed from view model
								Text(viewModel.textAttributedString)
									.font(.body)
									.lineLimit(15)
									.padding([.top])
									.accessibilityIdentifier("Description")
							}
						}
						.focusSection()
						
						// Like/dislike/comments row
						HStack {
							// Like button
							let additionalLikes = viewModel.isLiked && viewModel.latestUserInteraction != nil ? 1 : 0
							Button(action: {
								viewModel.like()
							}) {
								Image(systemName: viewModel.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
									.accessibility(hidden: true)
								Text("\(content.likes + additionalLikes)")
									.accessibilityLabel("Like")
									.accessibilityValue("\(content.likes + additionalLikes) likes")
									.accessibilityHint(viewModel.isLiked ? "Removes like from post" : "Likes the post")
							}
							.foregroundColor(viewModel.isLiked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)

							// Dislike button
							let additionalDislikes = viewModel.isDisliked && viewModel.latestUserInteraction != nil ? 1 : 0
							Button(action: {
								viewModel.dislike()
							}) {
								Image(systemName: viewModel.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
									.accessibility(hidden: true)
								Text("\(content.dislikes + additionalDislikes)")
									.accessibilityLabel("Dislike")
									.accessibilityValue("\(content.dislikes + additionalDislikes) dislikes")
									.accessibilityHint(viewModel.isLiked ? "Removes dislike from post" : "Dislikes the post")
							}
							.foregroundColor(viewModel.isDisliked ? FPColors.blue : colorScheme == .light ? Color.black : Color.white)

							// Comments label
							Text("\(content.comments) comment\(content.comments == 1 ? "" : "s")")
							
							// Extend the side, for focusSection behavior
							Spacer()
						}
						.frame(maxWidth: .infinity)
						.padding()
						.focusSection()
						
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
		BlogPostView(viewModel: BlogPostViewModel(fpApiService: MockFPAPIService(), id: "", state: .loaded(MockData.getBlogPost)), shouldAutoPlay: false)
	}
}
