import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostSelectionView: View {
	
	let blogPost: BlogPostModelV3
	
	@Environment(\.fpApiService) var fpApiService
	
	@State var isSelected = false
	
	var body: some View {
		Button(action: {
			isSelected = true
		}, label: {
			VStack {
				CachedAsyncImage(url: URL(string: blogPost.thumbnail.path), content: {
					$0
						.resizable()
						.scaledToFit()
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
				isSelected = true
			})
			.sheet(isPresented: $isSelected, onDismiss: {
				isSelected = false
			}, content: {
				BlogPostView(viewModel: BlogPostViewModel(fpApiService: fpApiService, id: blogPost.id))
			})
	}
}

struct BlogPostSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		BlogPostSelectionView(blogPost: MockData.blogPosts.blogPosts[0])
			.environment(\.fpApiService, MockFPAPIService())
	}
}
