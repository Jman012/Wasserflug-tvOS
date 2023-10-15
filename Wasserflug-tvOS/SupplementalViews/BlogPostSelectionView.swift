import SwiftUI
import FloatplaneAPIClient

private let relativeTimeConverter: RelativeDateTimeFormatter = {
	let formatter = RelativeDateTimeFormatter()
	formatter.unitsStyle = .full
	return formatter
}()

struct BlogPostSelectionView: View {
	
	let blogPost: BlogPostModelV3
	@State var geometrySize: CGSize?
	
	@EnvironmentObject var navCoordinator: NavigationCoordinator<WasserflugRoute>
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Button(action: {
				if blogPost.isAccessible {
					navCoordinator.push(route: .blogPostView(blogPostId: blogPost.id, autoPlay: false))
				}
			}, label: {
				// Thumbnail
				ZStack(alignment: .center) {
					MediaThumbnail(thumbnail: blogPost.thumbnail,
								   watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", blogPost.id, blogPost.firstVideoAttachmentId ?? ""), animation: .default))
					
					// Optional lock icon if the post is inaccessible.
					if !blogPost.isAccessible {
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
			})
			.buttonStyle(.card)
			.padding(.bottom)
			.onPlayPauseCommand(perform: {
				if blogPost.isAccessible {
					navCoordinator.push(route: .blogPostView(blogPostId: blogPost.id, autoPlay: true))
				}
			})
			
			// Below the image: title, length, tags, etc.
			HStack(alignment: .top, spacing: 0) {
				let profileImageSize: CGFloat = 35
				// Show the channel icon, regardless of view origin.
				if case let .typeChannelModel(channel) = blogPost.channel,
				   let channelIconUrl = URL(string: channel.icon.path) {
					AsyncImage(url: channelIconUrl, content: { image in
						image
							.resizable()
							.scaledToFit()
							.frame(width: profileImageSize, height: profileImageSize)
							.cornerRadius(profileImageSize / 2)
					}, placeholder: {
						ProgressView()
							.frame(width: profileImageSize, height: profileImageSize)
					})
					.padding([.trailing], 10)
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
						if !meta.hasVideo && !meta.hasAudio && !meta.hasPicture {
							AttachmentPill(text: "Text")
						}
						
						// Video/audio duration with clock icon
						let duration: TimeInterval = meta.videoCount == 1 ? meta.videoDuration : meta.audioCount == 1 ? meta.audioDuration : 0.0
						if duration != 0 {
							Image(systemName: "clock")
							Text("\(TimeInterval(duration).floatplaneTimestamp)")
								.lineLimit(1)
								.accessibilityLabel("Duration \(TimeInterval(duration).accessibleFloatplanetimestamp)")
						}
					}
					.font(.system(size: 18, weight: .light))
					
					HStack {
						// Creator name on bottom of card
						Text(verbatim: blogPost.channel.asChannelModel?.title ?? blogPost.creator.title)
						
						Spacer(minLength: 0)
						
						Text("\(relativeTimeConverter.localizedString(for: blogPost.releaseDate, relativeTo: Date()))")
							.lineLimit(1)
					}
					.font(.system(size: 18, weight: .light))
				}
			}
		}
		.focusSection()
	}
}

struct BlogPostSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		BlogPostSelectionView(
			blogPost: MockData.blogPosts.blogPosts.first!
		)
		.previewLayout(.fixed(width: 600, height: 500))
		BlogPostSelectionView(
			blogPost: MockData.blogPosts.blogPosts.first!
		)
		.previewLayout(.fixed(width: 600, height: 500))
	}
}
