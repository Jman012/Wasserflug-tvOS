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
					CachedAsyncImage(url: URL(string: blogPost.thumbnail.path), content: { image in
						ZStack(alignment: .bottomLeading) {
							image
								.resizable()
								.scaledToFit()
								.frame(maxWidth: .infinity, maxHeight: .infinity)
							GeometryReader { geometry in
								Rectangle()
									.fill(FPColors.blue)
									.frame(width: geometry.size.width * progress)
							}
								.frame(height: 8)
						}
						.cornerRadius(10.0)
					}, placeholder: {
						ProgressView()
							.frame(
								maxWidth: CGFloat(blogPost.thumbnail.width),
								maxHeight: CGFloat(blogPost.thumbnail.height)
							)
							.aspectRatio(blogPost.thumbnail.aspectRatio, contentMode: .fit)
					})
					
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
				
				HStack(alignment: .top, spacing: 0) {
					let profileImageSize: CGFloat = 35
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
						Text(verbatim: blogPost.title)
							.font(.caption2)
							.lineLimit(2)
						HStack(spacing: 10) {
							let meta = blogPost.metadata
							Text("\(meta.hasVideo ? "Video" : meta.hasAudio ? "Audio" : meta.hasGallery ? "Gallery" : "Picture")")
		//						.font(.caption2)
								.padding([.all], 5)
								.foregroundColor(.white)
								.background(.gray)
								.cornerRadius(10)
							
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
			.previewLayout(.fixed(width: 1000, height: 600))
//			.preferredColorScheme(.light)
		BlogPostSelectionView(
			blogPost: MockData.blogPosts.blogPosts.first!,
			viewOrigin: .creator,
			watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
		)
			.environment(\.fpApiService, MockFPAPIService())
			.previewLayout(.fixed(width: 1000, height: 600))
//			.preferredColorScheme(.light)
	}
}
