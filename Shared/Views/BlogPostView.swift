//
//  BlogPostView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI
import CachedAsyncImage

struct BlogPostView: View {
    @StateObject var viewModel: BlogPostViewModel
    
    @Environment(\.fpApiService) var fpApiService
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userInfo: UserInfo
    
    @FetchRequest var watchProgresses: FetchedResults<WatchProgress>
        
    var progress: CGFloat {
        if let watchProgress = watchProgresses.first {
            let progress = watchProgress.progress
            return progress >= 0.95 ? 1.0 : progress
        } else {
            return 0.0
        }
    }
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }
    
    // Ignore, just make it compatible with the tvOS version
    var shouldAutoPlay: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    switch viewModel.state {
                    case .idle:
                        Spacer()
                        ProgressView().onAppear(perform: {
                            viewModel.load(colorScheme: colorScheme)
                        })
                        Spacer()
                    case .loading:
                        Spacer()
                        ProgressView()
                        Spacer()
                    case let .failed(error):
                        ErrorView(error: error)
                    case let .loaded(content):
                        ScrollView {
                            if let videoAttachments = content.videoAttachments, let firstVideo = videoAttachments.first {
                                VideoView(viewModel: VideoViewModel(fpApiService: fpApiService, videoAttachment: firstVideo, contentPost: content, description: viewModel.textAttributedString), beginningWatchTime: progress)
                            } else {
                                CachedAsyncImage(url: content.thumbnail.pathUrlOrNil) { image in
                                    ZStack {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .blur(radius: 1.5)
                                        VStack {
                                            Spacer()
                                            Image(systemName: "play.slash")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 42, height: 42)
                                                .background(Circle().inset(by: -10).foregroundColor(.red))
                                            Spacer()
                                        }
                                    }
                                } placeholder: {
                                    VStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                            HStack {
                                Text(content.title)
                                    .font(.headline)
                                Spacer()
                            }
                                .padding(.horizontal)
                            HStack {
                                let profileImageSize: CGFloat = 35
                                if let user = userInfo.creatorOwners[content.creator.owner], let path = user.profileImage.path {
                                    CachedAsyncImage(url: URL(string: path), content: { image in
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
                                    HStack {
                                        Text(verbatim: content.creator.title)
                                            .font(.body)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(content.releaseDate, formatter: self.formatter)
                                            .font(.caption2)
                                        Spacer()
                                    }
                                }
                                HStack(alignment: .center) {
                                    Button {
                                        viewModel.like()
                                    } label: {
                                        let additional = viewModel.isLiked && viewModel.latestUserInteraction != nil ? 1 : 0
                                        Label("\(content.likes + additional)", systemImage: "hand.thumbsup")
                                    }
                                    .foregroundColor(viewModel.isLiked ? .green : colorScheme == .light ? .gray : .white)
                                    Button {
                                        viewModel.dislike()
                                    } label: {
                                        let additional = viewModel.isDisliked && viewModel.latestUserInteraction != nil ? 1 : 0
                                        Label("\(content.likes + additional)", systemImage: "hand.thumbsdown")
                                    }
                                    .foregroundColor(viewModel.isDisliked ? .red : colorScheme == .light ? .gray : .white)
                                }
                                Spacer()
                            }
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Blur navigation bar to recreate the translucent effect
                VStack {
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .light ? .light : .dark))
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 0)
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct BlogPostView_Previews: PreviewProvider {
    static var previews: some View {
        BlogPostView(viewModel: BlogPostViewModel(fpApiService: MockFPAPIService(), id: ""), watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", MockData.blogPosts.blogPosts.first!.id), animation: .default), shouldAutoPlay: false)
            .environmentObject(MockData.userInfo)
    }
}
