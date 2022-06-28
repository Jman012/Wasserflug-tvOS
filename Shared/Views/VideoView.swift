//
//  VideoView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 28/06/2022.
//

import SwiftUI
import AVKit
import FloatplaneAPIClient
import CachedAsyncImage

struct VideoView: View {
    
    @StateObject var viewModel: VideoViewModel
    let beginningWatchTime: Double
    
    var body: some View {
        switch viewModel.state {
        case .idle:
            Spacer()
            ProgressView().onAppear(perform: {
                viewModel.load()
            })
            Spacer()
        case .loading:
            CachedAsyncImage(url: self.viewModel.contentPost.thumbnail.pathUrlOrNil) { image in
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: 2)
                    VStack {
                        Spacer()
                        ProgressView()
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
        case let .failed(error):
            ErrorView(error: error)
        case let .loaded(content):
            VideoPlayerView(viewModel: viewModel, content: content, beginningWatchTime: beginningWatchTime)
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(viewModel: VideoViewModel(fpApiService: MockFPAPIService(), videoAttachment: MockData.getBlogPost.videoAttachments!.first!, contentPost: MockData.getBlogPost, description: "Test description"), beginningWatchTime: 0.0)
    }
}
