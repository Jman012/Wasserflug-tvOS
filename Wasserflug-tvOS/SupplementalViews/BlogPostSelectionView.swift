import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostSelectionView: View {
	
	let blogPost: BlogPostModelV3
	
	@Environment(\.fpApiService) var fpApiService
	
	@State var isSelected = false
	@State var shouldAutoPlay = false
	
	var body: some View {
		Button(action: {
			isSelected = true
		}, label: {
			VStack {
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
					.lineLimit(2)
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
