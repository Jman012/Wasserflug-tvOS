import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostSelectionView: View {
	
	let blogPost: BlogPostModelV3
	
	@Environment(\.fpApiService) var fpApiService
	
	@State var isSelected = false
	@State var shouldAutoPlay = false
	
	private let relativeTimeConverter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter
	}()
	
	var body: some View {
		Button(action: {
			isSelected = true
		}, label: {
			VStack(alignment: .leading, spacing: 2) {
				CachedAsyncImage(url: URL(string: blogPost.thumbnail.path), content: { image in
					image
						.resizable()
						.scaledToFit()
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.cornerRadius(10.0)
				}, placeholder: {
					ProgressView()
						.frame(
							maxWidth: CGFloat(blogPost.thumbnail.width),
							maxHeight: CGFloat(blogPost.thumbnail.height)
						)
						.aspectRatio(blogPost.thumbnail.aspectRatio, contentMode: .fit)
				})
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
				}
					.font(.system(size: 18, weight: .light))
			}
				.padding()
		})
			.buttonStyle(.plain)
			.onPlayPauseCommand(perform: {
				shouldAutoPlay = true
				isSelected = true
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
		BlogPostSelectionView(blogPost: MockData.blogPosts.blogPosts[0])
			.environment(\.fpApiService, MockFPAPIService())
	}
}
