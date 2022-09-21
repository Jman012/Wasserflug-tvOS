import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct PlayMediaView<Content>: View where Content: View {
	
	let thumbnail: ImageModelShared?
	let showPlayButton: Bool
	let width: CGFloat?
	let playButtonSize: PlayButton.Size
	let playContent: (Double) -> Content
	let defaultInNamespace: Namespace.ID?
	
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
		ZStack {
			CachedAsyncImage(url: thumbnail.pathUrlOrNil, content: { image in
				ZStack(alignment: .bottomLeading) {
					// Thumbnail image
					image
						.resizable()
						.scaledToFit()
						.frame(width: width)
					
					// Watch progress indicator
					GeometryReader { geometry in
						Rectangle()
							.fill(FPColors.blue)
							.frame(width: geometry.size.width * progress)
					}
						.frame(height: 8)
				}
					.frame(width: width)
					// Apply the cornerRadius on the ZStack to get the corners of the watch progress indicator
					.cornerRadius(10.0)
			}, placeholder: {
				ZStack {
					ProgressView()
					Rectangle()
						.fill(.clear)
						.frame(width: width)
						.aspectRatio(thumbnail?.aspectRatio ?? 1.0, contentMode: .fit)
				}
			})
			
			if showPlayButton {
				PlayButton(size: playButtonSize, action: {
					isShowingMedia = true
				})
					// If a namespace is provided, then prefer default focus on it.
					.optionalPrefersDefaultFocus(in: defaultInNamespace)
					.sheet(isPresented: $isShowingMedia, onDismiss: {
						isShowingMedia = false
					}, content: {
						playContent(Double(progress))
					})
			}
		}
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
				defaultInNamespace: nil,
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
			)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

			PlayMediaView(
				thumbnail: MockData.blogPosts.blogPosts.first!.thumbnail,
				showPlayButton: false,
				width: 500,
				playButtonSize: .default,
				playContent: { _ in EmptyView() },
				defaultInNamespace: nil,
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)				
			)
				.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

		}
	}
}
