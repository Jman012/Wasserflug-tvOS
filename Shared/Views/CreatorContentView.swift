//
//  CreatorContentView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI
import FloatplaneAPIClient
import CachedAsyncImage

struct CreatorContentView: View {
    @EnvironmentObject var userInfo: UserInfo
    @Environment(\.fpApiService) var fpApiService
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: CreatorContentViewModel
    @StateObject var livestreamViewModel: LivestreamViewModel
    
    @State var isShowingSearch = false
    @State var isShowingLive = false
    
    private var gridColumns: [GridItem] {
        return Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top), count: UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                ProgressView().onAppear(perform: {
                    viewModel.load()
                    livestreamViewModel.load()
                    livestreamViewModel.startLoadingLiveStatus()
                })
            case .loading:
                ProgressView()
            case let .failed(error):
                ErrorView(error: error)
            case let .loaded(content):
                ScrollView {
                    GeometryReader { geometry in
                        ZStack {
                            CachedAsyncImage(url: viewModel.coverImagePath, content: { image in
                                if geometry.frame(in: .global).minY <= 0 {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                    //.offset(y: geometry.frame(in: .global).minY/9)
                                        .clipped()
                                } else {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                                        .clipped()
                                        .offset(y: -geometry.frame(in: .global).minY)
                                }
                            }, placeholder: {
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(viewModel.creator.cover?.aspectRatio ?? 1.0, contentMode: .fit)
                            })
                        }
                    }
                    .frame(height: viewModel.coverImageWidth != nil && viewModel.coverImageHeight != nil ? ( UIScreen.main.bounds.size.width / viewModel.coverImageWidth!) * viewModel.coverImageHeight! : 150)
                    
                    let offset: CGFloat = 70 / 2
                    
                    HStack {
                        let logoSize: CGFloat = 70
                        CachedAsyncImage(url: viewModel.creatorProfileImagePath, content: { image in
                            image
                                .resizable()
                                .frame(width: logoSize, height: logoSize)
                                .clipShape(Circle())
                        }, placeholder: {
                            ProgressView()
                                .frame(width: logoSize, height: logoSize)
                        })
                        .offset(y: -offset)
                        VStack {
                            Text(viewModel.creatorAboutHeader)
                                .fontWeight(.bold)
                                .font(.system(.headline))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text(viewModel.creatorAboutBody)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .offset(y: -offset)
                    
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(content) { blogPost in
                            BlogPostSelectionView(
                                blogPost: blogPost,
                                viewOrigin: .creator,
                                watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", blogPost.id), animation: .default)
                            )
                            .onAppear(perform: {
                                viewModel.itemDidAppear(blogPost)
                            })
                        }
                    }
                    .padding(.horizontal)
                    .offset(y: -offset)
                }
                .onDisappear {
                    viewModel.creatorContentDidDisappear()
                }.onAppear {
                    viewModel.creatorContentDidAppearAgain()
                    livestreamViewModel.loadLiveStatus()
                }
            }
        }
    }
    
}

struct CreatorContentView_Previews: PreviewProvider {
    @State static var selection = RootTabView.Selection.creator(MockData.creators[0].id)
    static var previews: some View {
        TabView(selection: $selection) {
            Text("test").tabItem {
                Text("Home")
            }
            CreatorContentView(viewModel: CreatorContentViewModel(
                fpApiService: MockFPAPIService(),
                creator: MockData.creators[0],
                creatorOwner: MockData.creatorOwners.users[0].user
            ), livestreamViewModel: LivestreamViewModel(
                fpApiService: MockFPAPIService(),
                creator: MockData.creators[0])
            )
            .tag(RootTabView.Selection.creator(MockData.creators[0].id))
            .tabItem {
                Text(MockData.creators[0].title)
            }
            .environmentObject(MockData.userInfo)
            Text("test").tabItem {
                Text("Settings")
            }
        }
    }
}

