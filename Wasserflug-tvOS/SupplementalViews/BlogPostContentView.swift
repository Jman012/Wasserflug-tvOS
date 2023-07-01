import SwiftUI
import FloatplaneAPIClient

struct BlogPostContentView: View {
	
	let geometry: GeometryProxy
	let content: ContentPostV3Response
	let fpApiService: FPAPIService
	let description: AttributedString
	
	@State var shownVideoAttachment: VideoAttachmentModel? = nil
	@State var showingPicture: PictureAttachmentModel? = nil
	@State var showAudioAttachmentFeatureMissing = false
	
	@EnvironmentObject var navCoordinator: NavigationCoordinator<WasserflugRoute>
	
	var orderedAttachmentIds: [String: Int] {
		return content.attachmentOrder.enumerated().reduce(into: [String: Int](), { $0[$1.element] = $1.offset })
	}
	
	var orderedVideoAttachments: [VideoAttachmentModel]? {
		if let videoAttachments = content.videoAttachments {
			return videoAttachments.sorted(by: { (a, b) -> Bool in
				return orderedAttachmentIds[a.id] ?? 0 < orderedAttachmentIds[b.id] ?? 0
			})
		} else {
			return nil
		}
	}
	
	var orderedPictureAttachments: [PictureAttachmentModel]? {
		if let pictureAttachments = content.pictureAttachments {
			return pictureAttachments.sorted(by: { (a, b) -> Bool in
				return orderedAttachmentIds[a.id] ?? 0 < orderedAttachmentIds[b.id] ?? 0
			})
		} else {
			return nil
		}
	}
	
	var orderedAudioAttachments: [AudioAttachmentModel]? {
		if let audioAttachments = content.audioAttachments {
			return audioAttachments.sorted(by: { (a, b) -> Bool in
				return orderedAttachmentIds[a.id] ?? 0 < orderedAttachmentIds[b.id] ?? 0
			})
		} else {
			return nil
		}
	}
	
	var body: some View {
		if let videoAttachments = orderedVideoAttachments, !videoAttachments.isEmpty {
			Text("Videos")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(videoAttachments) { video in
						VStack {
							PlayMediaView(
								thumbnail: video.thumbnail,
								viewMode: .playButton,
								width: geometry.size.width * 0.2,
								playButtonSize: .small,
								videoTitle: video.title,
								playContent: { beginningWatchTime in
									navCoordinator.push(route: .videoView(videoAttachment: video, content: content, description: description, beginningWatchTime: beginningWatchTime))
								},
								autoPlay: false,
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
		if let pictureAttachments = orderedPictureAttachments, !pictureAttachments.isEmpty {
			Text("Pictures")
				.font(.headline)
			ScrollView(.horizontal) {
				HStack {
					ForEach(pictureAttachments) { picture in
						VStack {
							Button(action: {
								showingPicture = picture
							}, label: {
								AsyncImage(url: URL(string: picture.thumbnail.path), content: { image in
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
		if let audioAttachments = orderedAudioAttachments, !audioAttachments.isEmpty {
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
