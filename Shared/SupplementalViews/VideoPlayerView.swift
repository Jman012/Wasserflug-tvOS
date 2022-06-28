//
//  VideoPlayerView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 26/06/2022.
//

import SwiftUI
import FloatplaneAPIClient
import AVKit

struct VideoPlayerView: View {
    @ObservedObject var viewModel: VideoViewModel
    
    @State var videoWidth: CGFloat = UIScreen.main.bounds.width

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    let content: CdnDeliveryV2Response
    let beginningWatchTime: Double
        
    // Get the aspect ratio of the video content
    var aspectRatio: CGFloat {
        let height = content.resource.data.qualityLevels?.first?.height ?? 9
        let width = content.resource.data.qualityLevels?.first?.width ?? 16
        let aspectRatio = CGFloat(CGFloat(height) / CGFloat(width))
        return aspectRatio
    }
    
    var body: some View {
        VStack {
            VideoPlayerViewWrapped(viewModel: viewModel, content: content, beginningWatchTime: beginningWatchTime)
                .frame(width: videoWidth, height: aspectRatio * videoWidth)
        }
        .onReceive(orientationChanged) { _ in
            DispatchQueue.main.async {
                self.videoWidth = UIScreen.main.bounds.width
            }
        }
    }
}

struct VideoPlayerViewWrapped: UIViewControllerRepresentable {
    @AppStorage("DesiredQuality") var desiredQuality: String = ""
    @ObservedObject var viewModel: VideoViewModel
    
    let content: CdnDeliveryV2Response
    let beginningWatchTime: Double
    
    func makeUIViewController(context: Context) -> ExtendedAVPlayerViewController {
        let vc = ExtendedAVPlayerViewController()
        vc.delegate = context.coordinator
        let playerItem = viewModel.createAVPlayerItem(desiredQuality: desiredQuality)
        if beginningWatchTime > 0.0 && beginningWatchTime < 1.0 {
            let totalSeconds = viewModel.videoAttachment.duration
            let percentageOfTotal = beginningWatchTime
            let seekToSeconds = totalSeconds * percentageOfTotal
            let newCMTime = CMTime(seconds: seekToSeconds, preferredTimescale: 1)
            playerItem.seek(to: newCMTime, completionHandler: nil)
        }
        vc.player = AVPlayer(playerItem: playerItem)
        vc.player?.play() // Needs to play when it first appears.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ExtendedAVPlayerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        let parent: VideoPlayerViewWrapped
        
        init(_ parent: VideoPlayerViewWrapped) {
            self.parent = parent
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            let extendedPlayerViewController = playerViewController as! ExtendedAVPlayerViewController
            extendedPlayerViewController.isStatusBarHidden = false
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            let extendedPlayerViewController = playerViewController as! ExtendedAVPlayerViewController
            extendedPlayerViewController.isStatusBarHidden = true
        }
    }
}

class ExtendedAVPlayerViewController: AVPlayerViewController {
    var isStatusBarHidden: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
}

//struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
//}
