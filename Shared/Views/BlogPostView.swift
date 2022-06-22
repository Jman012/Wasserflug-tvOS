//
//  BlogPostView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 22.06.22.
//

import SwiftUI

struct BlogPostView: View {
    @StateObject var viewModel: BlogPostViewModel
    
    // Ignore, just make it compatible with the tvOS version
    var shouldAutoPlay: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BlogPostView_Previews: PreviewProvider {
    static var previews: some View {
        BlogPostView(viewModel: BlogPostViewModel(fpApiService: MockFPAPIService(), id: ""), shouldAutoPlay: false)
    }
}
