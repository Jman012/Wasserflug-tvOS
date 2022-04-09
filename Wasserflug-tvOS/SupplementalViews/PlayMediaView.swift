import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct PlayMediaView<Content>: View where Content: View {
	
	let thumbnail: ImageModel
	let showPlayButton: Bool
	let width: CGFloat?
	let playButtonSize: PlayButton.Size
	let playContent: (Double) -> Content
	
	@State var isShowingMedia = false
	
	@FetchRequest var watchProgresses: FetchedResults<WatchProgress>
	
	var progress: CGFloat {
		if let watchProgress = watchProgresses.first {
			let progress = watchProgress.progress
			return progress >= 0.95 ? 1.0 : progress
		} else {
			return 0.0
		}
	}
	
	var body: some View {
		ZStack {
			if showPlayButton {
				image
			} else {
				Button(action: {
					isShowingMedia = true
				}, label: {
					image
				})
					.buttonStyle(.card)
					.padding()
			}
		}
	}
	
	var image: some View {
		CachedAsyncImage(url: URL(string: thumbnail.path), content: { image in
			ZStack {
				ZStack(alignment: .bottomLeading) {
					image
						.resizable()
						.scaledToFit()
						.frame(width: width)
					GeometryReader { geometry in
						Rectangle()
							.fill(FPColors.blue)
							.frame(width: geometry.size.width * progress)
					}
						.frame(height: 8)
				}
					.frame(width: width)
				
				if showPlayButton {
					PlayButton(size: playButtonSize, action: {
						isShowingMedia = true
					})
//						.prefersDefaultFocus(in: screenNamespace)
						.sheet(isPresented: $isShowingMedia, onDismiss: {
							isShowingMedia = false
						}, content: {
							playContent(Double(progress))
						})
				}
			}
				.cornerRadius(10.0)
		}, placeholder: {
			ZStack {
				ProgressView()
				Rectangle()
					.fill(.clear)
					.frame(width: width)
					.aspectRatio(thumbnail.aspectRatio, contentMode: .fit)
			}
		})
	}
}

struct PlayMediaView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			PlayMediaView(
				thumbnail: MockData.blogPosts.blogPosts.first!.thumbnail,
				showPlayButton: true,
				width: 200,
				playButtonSize: .small,
				playContent: { _ in EmptyView() },
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
			)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

			PlayMediaView(
				thumbnail: MockData.blogPosts.blogPosts.first!.thumbnail,
				showPlayButton: false,
				width: 500,
				playButtonSize: .default,
				playContent: { _ in EmptyView() },
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)				
			)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

		}
	}
}
