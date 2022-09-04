import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostSelectionView: View {
	
	enum ViewOrigin: Equatable {
		case home(UserModel?)
		case creator
	}
	
	let blogPost: BlogPostModelV3
	let viewOrigin: ViewOrigin
	@FetchRequest var watchProgresses: FetchedResults<WatchProgress>
	
	@Environment(\.fpApiService) var fpApiService
	@Environment(\.managedObjectContext) private var viewContext

	@State var isSelected = false
	@State var shouldAutoPlay = false
	
	private let relativeTimeConverter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter
	}()
	
	var progress: CGFloat {
		if let watchProgress = watchProgresses.first(where: { $0.videoId == blogPost.videoAttachments?.first }) {
			let progress = watchProgress.progress
			return progress >= 0.95 ? 1.0 : progress
		} else {
			return 0.0
		}
	}
	
	var body: some View {
		Button(action: {
			if blogPost.isAccessible {
				isSelected = true
			}
		}, label: {
			VStack(alignment: .leading, spacing: 2) {
				ZStack(alignment: .center) {
					CachedAsyncImage(url: blogPost.thumbnail.pathUrlOrNil, content: { image in
						// Thumbnail image with watch progress indicator overlaid on
						// the bottom of the image
						ZStack(alignment: .bottomLeading) {
							// Thumbnail image
							image
								.resizable()
								.scaledToFit()
								.frame(maxWidth: .infinity, maxHeight: .infinity)
							
							// Watch progress indicator
							GeometryReader { geometry in
								Rectangle()
									.fill(FPColors.blue)
									.frame(width: geometry.size.width * progress)
							}
								.frame(height: 8)
						}
						.cornerRadius(10.0)
					}, placeholder: {
						ZStack {
							ProgressView()
							Rectangle()
								.fill(.clear)
								.frame(maxWidth: .infinity, maxHeight: .infinity)
								.aspectRatio(blogPost.thumbnail?.aspectRatio ?? 1.0, contentMode: .fit)
						}
					})
					
					// Optional lock icon if the post is inaccessible.
					if (!blogPost.isAccessible) {
						VisualEffectView(effect: UIBlurEffect(style: .dark))
							.frame(width: 150, height: 150)
							.cornerRadius(75.0)
						Image(systemName: "lock.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 100, height: 100)
							.foregroundColor(.white)
							
					}
				}
				
				// Below the image: title, length, tags, etc.
				HStack(alignment: .top, spacing: 0) {
					let profileImageSize: CGFloat = 35
					// For the home screen, show the icon/profile picture of the
					// creator that published the blog post.
					if case let .home(creatorOwner) = viewOrigin,
					   let profileImagePath = creatorOwner?.profileImage.path,
					   let profileImageUrl = URL(string: profileImagePath) {
						CachedAsyncImage(url: profileImageUrl, content: { image in
							image
								.resizable()
								.scaledToFit()
								.frame(width: profileImageSize, height: profileImageSize)
								.cornerRadius(profileImageSize / 2)
						}, placeholder: {
							ProgressView()
								.frame(width: profileImageSize, height: profileImageSize)
						})
							.padding([.all], 5)
					}
					
					VStack(alignment: .leading, spacing: 4) {
						// Blog post title
						Text(verbatim: blogPost.title)
							.font(.caption2)
							.lineLimit(2)
						
						// Video/Audio/Gallery/Picture tags
						HStack(spacing: 10) {
							let meta = blogPost.metadata
							if meta.hasVideo {
								AttachmentPill(text: "Video")
							}
							if meta.hasAudio {
								AttachmentPill(text: "Audio")
							}
							if meta.hasPicture {
								AttachmentPill(text: "Picture")
							}
							if meta.hasGallery {
								AttachmentPill(text: "Gallery")
							}
							if !meta.hasVideo && !meta.hasAudio && !meta.hasPicture && !meta.hasGallery {
								AttachmentPill(text: "Text")
							}
							
							// Video/audio duration with clock icon
							let duration: TimeInterval = meta.hasVideo ? meta.videoDuration : meta.hasAudio ? meta.audioDuration : 0.0
							if duration != 0 {
								Image(systemName: "clock")
								Text("\(TimeInterval(duration).floatplaneTimestamp)")
							}
							Spacer()
							Text("\(relativeTimeConverter.localizedString(for: blogPost.releaseDate, relativeTo: Date()))")
								.lineLimit(1)
						}
							.font(.system(size: 18, weight: .light))
						
						// Creator name on bottom of card
						if case .home(_) = viewOrigin {
							Text(verbatim: blogPost.creator.title)
								.font(.system(size: 18, weight: .light))
						}
					}
				}
			}
				.padding()
		})
			.buttonStyle(.plain)
			.onPlayPauseCommand(perform: {
				if blogPost.isAccessible {
					shouldAutoPlay = true
					isSelected = true
				}
			})
			.sheet(isPresented: $isSelected, onDismiss: {
				shouldAutoPlay = false
				isSelected = false
			}, content: {
				BlogPostView(viewModel: BlogPostViewModel(fpApiService: fpApiService, id: blogPost.id), shouldAutoPlay: shouldAutoPlay)
			})
	}
}

struct BlogPostSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		BlogPostSelectionView(
			blogPost: MockData.blogPosts.blogPosts.first!,
			viewOrigin: .home(MockData.creatorOwners.users.first!.user),
			watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
		)
			.environment(\.fpApiService, MockFPAPIService())
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
			.previewLayout(.fixed(width: 600, height: 400))
//			.preferredColorScheme(.light)
		BlogPostSelectionView(
			blogPost: MockData.blogPosts.blogPosts.first!,
			viewOrigin: .creator,
			watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
		)
			.environment(\.fpApiService, MockFPAPIService())
			.previewLayout(.fixed(width: 600, height: 400))
//			.preferredColorScheme(.light)
	}
}
