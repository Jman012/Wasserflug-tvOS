//
//  HomeView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    @EnvironmentObject var userInfo: UserInfo
    
    private var gridColumns: [GridItem] {
        return Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), alignment: .top), count: UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
    }
    
    var body: some View {
        switch viewModel.state {
        case .idle:
            Color.clear.onAppear(perform: {
                viewModel.load()
            })
        case .loading:
            ProgressView()
        case let .failed(error):
            ErrorView(error: error)
        case let .loaded(response):
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(response.blogPosts) { blogPost in
                        BlogPostSelectionView(
                            blogPost: blogPost,
                            viewOrigin: .home(userInfo.creatorOwners[blogPost.creator.owner.id]),
                            watchProgresses: FetchRequest(entity: WatchProgress.entity(), sortDescriptors: [], predicate: NSPredicate(format: "blogPostId = %@", blogPost.id), animation: .default)
                        )
                            .onAppear(perform: {
                                viewModel.itemDidAppear(blogPost)
                            })
                    }
                }
                .padding()
            }.onDisappear {
                viewModel.homeDidDisappear()
            }.onAppear {
                viewModel.homeDidAppearAgain()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(userInfo: MockData.userInfo, fpApiService: MockFPAPIService()))
            .environmentObject(MockData.userInfo)
    }
}
