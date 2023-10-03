import SwiftUI
import FloatplaneAPIClient

struct PlayMediaView: View {
	
	enum ViewMode {
		case playButton
		case imageCard
	}
	
	let thumbnail: ImageModelShared?
	let viewMode: ViewMode
	let playButtonSize: PlayButton.Size
	let videoTitle: String
	let playContent: (Double) -> Void
	let autoPlay: Bool
	
	@FetchRequest var watchProgresses: FetchedResults<WatchProgress>
	@FocusState private var isFocused
	
	var progress: CGFloat {
		if let watchProgress = watchProgresses.first {
			let progress = watchProgress.progress
			return progress >= 0.95 ? 1.0 : progress
		} else {
			return 0.0
		}
	}
	
	var body: some View {
		switch viewMode {
		case .playButton:
			ZStack {
				image
				
				PlayButton(size: playButtonSize, videoTitle: videoTitle, action: {
					self.playContent(progress)
				})
				.focused($isFocused)
				.onFirstAppear {
					if autoPlay {
						Task { @MainActor in
							// Issues with it happening too quickly when the view appears not working.
							try? await Task.sleep(for: .milliseconds(500))
							self.playContent(progress)
						}
					}
				}
			}
		case .imageCard:
			Button(action: {
				self.playContent(progress)
			}, label: {
				image
			})
			.buttonStyle(.card)
			.focused($isFocused)
			.padding()
			.onFirstAppear {
				if autoPlay {
					self.playContent(progress)
				}
			}
		}
	}
	
	var image: some View {
		MediaThumbnail(thumbnail: thumbnail, watchProgresses: _watchProgresses)
	}
}

struct PlayMediaView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			PlayMediaView(
				thumbnail: MockData.blogPosts.blogPosts.first!.thumbnail,
				viewMode: .playButton,
				playButtonSize: .small,
				videoTitle: "video title here",
				playContent: { _ in },
				autoPlay: false,
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
			)
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

			PlayMediaView(
				thumbnail: MockData.blogPosts.blogPosts.first!.thumbnail,
				viewMode: .imageCard,
				playButtonSize: .default,
				videoTitle: "video title here",
				playContent: { _ in },
				autoPlay: false,
				watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
			)
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		}
	}
}
