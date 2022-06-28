//
//  BlogPostSelectionView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct BlogPostSelectionView: View {
    enum ViewOrigin: Equatable {
        case home(UserModel?)
        case creator
    }
    
    let blogPost: BlogPostModelV3
    let viewOrigin: ViewOrigin
    @FetchRequest var watchProgresses: FetchedResults<WatchProgress>
    
    @Environment(\.fpApiService) var fpApiService
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var clickedOnVideo = false;
    
    var progress: CGFloat {
        if let watchProgress = watchProgresses.first(where: { $0.videoId == blogPost.videoAttachments?.first }) {
            let progress = watchProgress.progress
            return progress >= 0.95 ? 1.0 : progress
        } else {
            return 0.0
        }
    }
    
    private let relativeTimeConverter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        let meta = blogPost.metadata
        
        NavigationLink("Link to Video", isActive: $clickedOnVideo) {
            BlogPostView(viewModel: BlogPostViewModel(fpApiService: fpApiService, id: blogPost.id), watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@ and videoId = %@", blogPost.id, blogPost.videoAttachments?.first ?? "")), shouldAutoPlay: true)
        }
            .hidden()
        
        VStack {
            CachedAsyncImage(url: blogPost.thumbnail.pathUrlOrNil, content: { image in
                ZStack(alignment: .bottomLeading) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    VStack {
                        HStack {
                            Spacer()
                            let duration: TimeInterval = meta.hasVideo ? meta.videoDuration : meta.hasAudio ? meta.audioDuration : 0.0
                            if duration != 0 {
                                HStack {
                                    Text("\(TimeInterval(duration).floatplaneTimestamp)")
                                        .colorInvert()
                                }
                                .padding([.leading, .trailing], 5)
                                .background(FPColors.darkBlue)
                                .cornerRadius(10.0, corners: [.bottomLeft])
                            }
                        }
                        Spacer()
                    }
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(FPColors.blue)
                            .frame(width: geometry.size.width * progress)
                    }
                        .frame(height: 4)
                }
                .cornerRadius(10.0)
            }, placeholder: {
                ZStack {
                    ProgressView()
                    VStack {
                        HStack {
                            Spacer()
                            let duration: TimeInterval = meta.hasVideo ? meta.videoDuration : meta.hasAudio ? meta.audioDuration : 0.0
                            if duration != 0 {
                                HStack {
                                    Text("\(TimeInterval(duration).floatplaneTimestamp)")
                                }
                                .padding([.leading, .trailing], 5)
                            }
                        }
                        Spacer()
                    }
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(blogPost.thumbnail?.aspectRatio ?? 1.0, contentMode: .fit)
                }
            })
            HStack {
                let profileImageSize: CGFloat = 35
                if case let .home(creatorOwner) = viewOrigin,
                   let profileImagePath = creatorOwner?.profileImage.path,
                   let profileImageUrl = URL(string: profileImagePath) {
                    CachedAsyncImage(url: profileImageUrl, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: profileImageSize, height: profileImageSize)
                            .cornerRadius(profileImageSize / 2)
                    }, placeholder: {
                        ProgressView()
                            .frame(width: profileImageSize, height: profileImageSize)
                    })
                        .padding([.all], 5)
                }
                VStack {
                    Text(verbatim: blogPost.title)
                        .font(.body)
                        .lineLimit(2)
                }
                Spacer()
            }
            HStack {
                Text("\(meta.hasVideo ? "Video" : meta.hasAudio ? "Audio" : meta.hasGallery ? "Gallery" : "Picture")")
                    .font(.caption2)
                    .padding([.all], 7)
                    .foregroundColor(.white)
                    .background(.gray)
                    .cornerRadius(10)
                
                if case .home(_) = viewOrigin {
                    Text(verbatim: blogPost.creator.title)
                        .font(.system(size: 18, weight: .light))
                }
                Spacer()
                Text("\(relativeTimeConverter.localizedString(for: blogPost.releaseDate, relativeTo: Date()))")
                    .lineLimit(1)
            }
        }.onTapGesture {
            self.clickedOnVideo.toggle()
        }
    }
}

struct BlogPostSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BlogPostSelectionView(
                blogPost: MockData.blogPosts.blogPosts.first!,
                viewOrigin: .home(MockData.creatorOwners.users.first!.user),
                watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default)
            )
                .environment(\.fpApiService, MockFPAPIService())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .padding(.all)
    }
}
