import SwiftUI
import FloatplaneAPIClient

struct MediaThumbnail: View {
	let thumbnail: ImageModelShared?
	@FetchRequest var watchProgresses: FetchedResults<WatchProgress>
	
	@State private var geometrySize: CGSize?
	@Environment(\.isFocused) private var isFocused
	
	var progress: CGFloat {
		if let watchProgress = watchProgresses.first {
			let progress = watchProgress.progress
			return progress >= 0.95 ? 1.0 : progress
		} else {
			return 0.0
		}
	}
	
	var body: some View {
		Group {
			if let thumbnail {
				AsyncImage(url: (thumbnail as ImageModelShared).bestImage(for: geometrySize), content: { image in
					image
						.resizable()
						.scaledToFit()
						.frame(maxWidth: .infinity)
				}, placeholder: {
					ZStack {
						ProgressView()
						Rectangle()
							.fill(.clear)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
							.aspectRatio(thumbnail.aspectRatio, contentMode: .fit)
					}
				})
			} else {
				// No thumbnail, use grey background color as placeholder
				Rectangle()
					.fill(Color(red: 221.0/256.0, green: 221.0/256.0, blue: 221.0/256.0))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.aspectRatio(1920.0 / 1080.0, contentMode: .fit)
			}
		}
		.accessibilityLabel(progress == 0 ? "Not watched" : progress == 1 ? "Watched" : "\(Int(progress * 100)) percent watched")
		.overlay {
			GeometryReader { geometry in
				ExecuteCode {
					if geometry.size.width > 40 && geometry.size.height > 40 {
						DispatchQueue.main.async {
							self.geometrySize = geometry.size
						}
					}
				}
				
				VStack {
					Spacer()
					Rectangle()
						.fill(LinearGradient(colors: [FPColors.watchProgressIndicatorBegin, FPColors.watchProgressIndicatorEnd], startPoint: .leading, endPoint: .trailing))
						.frame(width: geometry.size.width, height: isFocused ? 16 : 8)
						.mask(alignment: .leading) {
							Rectangle().frame(width: geometry.size.width * progress)
						}
						.animation(.spring(), value: isFocused)
				}
			}
		}
		.cornerRadius(10.0)
	}
}

struct MediaThumbnail_Previews: PreviewProvider {
	static let multiSizedThumbnail: ImageModel = .init(
		width: 1920,
		height: 1080,
		path: "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/567667542019112_1635554358724.jpeg",
		childImages: [
			.init(width: 400,
				  height: 225,
				  path: "https://pbs.floatplane.com/stream_thumbnails/5c13f3c006f1be15e08e05c0/894654974252956_1549059179026_400x225.jpeg"),
		])
	
	static var previews: some View {
		Group {
			MediaThumbnail(thumbnail: nil,
						   watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", PersistenceController.previewBlogPostId, PersistenceController.previewVideoId25), animation: .default)
			)
			.frame(width: 1920, height: 1080)
			.previewDisplayName("No thumbnail, 25%")
			
			MediaThumbnail(thumbnail: Self.multiSizedThumbnail,
						   watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", PersistenceController.previewBlogPostId, PersistenceController.previewVideoId50), animation: .default)
			)
			.frame(width: 1920, height: 1080)
			.previewDisplayName("Normal Large, 50%")
			
			MediaThumbnail(thumbnail: Self.multiSizedThumbnail,
						   watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", PersistenceController.previewBlogPostId, PersistenceController.previewVideoId75), animation: .default)
			)
			.frame(width: 400, height: 225)
			.previewDisplayName("Normal Small, 75%")
		}
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.ignoresSafeArea()
	}
}
