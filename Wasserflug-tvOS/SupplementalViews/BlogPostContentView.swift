import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostContentView: View {
	
	let geometry: GeometryProxy
	let content: ContentPostV3Response
	let fpApiService: FPAPIService
	
	@State var shownVideoAttachment: VideoAttachmentModel? = nil
	@State var showingPicture: PictureAttachmentModel? = nil
	
	var body: some View {
		if !content.videoAttachments.isEmpty {
			Text("Videos")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(content.videoAttachments) { video in
						VStack {
							PlayMediaView(
								thumbnail: video.thumbnail,
								showPlayButton: true,
								width: geometry.size.width * 0.2,
								playButtonSize: .small,
								playContent: {
									VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: video, contentPost: content))
								},
								watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", content.id, video.id), animation: .default)
)
//								.frame(maxWidth: geometry.size.width * 0.2)
//								CachedAsyncImage(url: URL(string: video.thumbnail.path), content: { image in
//									image
//										.resizable()
//										.scaledToFit()
//										.frame(maxWidth: geometry.size.width * 0.2)
//										.cornerRadius(10.0)
//								}, placeholder: {
//									ProgressView()
//										.frame(width: geometry.size.width * 0.2)
//										.aspectRatio(content.thumbnail.aspectRatio, contentMode: .fit)
//								})
//								PlayButton(size: .small, action: {
//									self.shownVideoAttachment = video
//								})
//									.sheet(item: $shownVideoAttachment, onDismiss: {
//										shownVideoAttachment = nil
//									}, content: { item in
//										VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: item, contentPost: content))
//									})
							Text(video.title)
//								.frame(maxWidth: geometry.size.width * 0.2)
								.lineLimit(1)
						}
							.frame(maxWidth: geometry.size.width * 0.2)
							.padding()
					}
				}
				Spacer()
			}
			.focusSection()
		}
		if !content.pictureAttachments.isEmpty {
			Text("Pictures")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(content.pictureAttachments) { picture in
						VStack {
							Button(action: {
								showingPicture = picture
							}, label: {
								CachedAsyncImage(url: URL(string: picture.thumbnail.path), content: { image in
									image
										.resizable()
										.scaledToFit()
										.frame(width: geometry.size.width * 0.2)
										.cornerRadius(10.0)
								}, placeholder: {
									ProgressView()
										.frame(width: geometry.size.width * 0.2)
										.aspectRatio(content.thumbnail.aspectRatio, contentMode: .fit)
								})
									.frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2 / content.thumbnail.aspectRatio)
							})
								.buttonStyle(.card)
								.padding()
							Text(picture.title)
								.frame(maxWidth: geometry.size.width * 0.2)
								.lineLimit(1)
						}
					}
				}
				Spacer()
			}
				.focusSection()
				.sheet(item: $showingPicture, onDismiss: {
					showingPicture = nil
				}, content: { item in
					PictureView(viewModel: PictureViewModel(fpApiService: fpApiService, pictureAttachment: item))
				})
		}
		if !content.galleryAttachments.isEmpty {
			Text("Galleries")
				.font(.headline)
		}
		if !content.audioAttachments.isEmpty {
			Text("Audios")
				.font(.headline)
		}
	}
}

struct BlogPostContentView_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				BlogPostContentView(geometry: geometry, content: MockData.getBlogPost, fpApiService: MockFPAPIService())
			}
		}
	}
}
