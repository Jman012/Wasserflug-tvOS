import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostContentView: View {
	
	let geometry: GeometryProxy
	let content: ContentPostV3Response
	let fpApiService: FPAPIService
	let description: AttributedString
	
	@State var shownVideoAttachment: VideoAttachmentModel? = nil
	@State var showingPicture: PictureAttachmentModel? = nil
	@State var showAudioAttachmentFeatureMissing = false
	
	var body: some View {
		if let videoAttachments = content.videoAttachments, !videoAttachments.isEmpty {
			Text("Videos")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(videoAttachments) { video in
						VStack {
							PlayMediaView(
								thumbnail: video.thumbnail,
								showPlayButton: true,
								width: geometry.size.width * 0.2,
								playButtonSize: .small,
								playContent: { beginningWatchTime in
									VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: video, contentPost: content, description: description), beginningWatchTime: beginningWatchTime)
								},
								defaultInNamespace: nil,
								watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", content.id, video.id), animation: .default)
							)
							Text(video.title)
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
		if let pictureAttachments = content.pictureAttachments, !pictureAttachments.isEmpty {
			Text("Pictures")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(pictureAttachments) { picture in
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
										.aspectRatio(content.thumbnail?.aspectRatio ?? 1.0, contentMode: .fit)
								})
								.frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2 / (content.thumbnail?.aspectRatio ?? 1.0))
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
						.overlay(alignment: .topTrailing, content: {
							ToastBarView()
						})
				})
		}
		if let galleryAttachments = content.galleryAttachments, !galleryAttachments.isEmpty {
			Text("Galleries")
				.font(.headline)
		}
		if let audioAttachments = content.audioAttachments, !audioAttachments.isEmpty {
			Text("Audio")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(audioAttachments) { audio in
						VStack {
							Button(action: {
								showAudioAttachmentFeatureMissing = true
							}, label: {
								let width = geometry.size.width * 0.2 // 20% of screen width works well
								let height = width / (1920.0 / 1080.0) // Scaled to 1080p aspect ratio of width
								WaveformView(waveform: audio.waveform,
											 width: width - 40, // 40pt of padding on either side
											 height: height * 0.5) // Half height for wave form
										.frame(width: width, height: height)
										.background(.black)
							})
								.buttonStyle(.card)
								.padding()
								.alert("Coming soon", isPresented: $showAudioAttachmentFeatureMissing, actions: {}, message: {
									Text("This feature is coming soon.")
								})
							Text(audio.title)
								.frame(maxWidth: geometry.size.width * 0.2)
								.lineLimit(1)
						}
					}
				}
				Spacer()
			}
				.focusSection()
		}
	}
}

struct BlogPostContentView_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				BlogPostContentView(geometry: geometry, content: MockData.getBlogPost, fpApiService: MockFPAPIService(), description: "Test description")
			}
		}
	}
}
