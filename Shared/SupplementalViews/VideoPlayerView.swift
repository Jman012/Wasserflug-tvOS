//
//  VideoPlayerView.swift
//  Wasserflug-tvOS
//
//  Created by Nils Bergmann on 26/06/2022.
//

import AVKit
import FloatplaneAPIClient
import SwiftUI
import Logging

struct VideoPlayerView: View {
	@ObservedObject var viewModel: VideoViewModel
	
	@Environment(\.screenWidth) var videoWidth: CGFloat
	
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
		VideoPlayerViewWrapped(viewModel: viewModel, content: content, beginningWatchTime: beginningWatchTime)
			.frame(width: self.videoWidth, height: aspectRatio * self.videoWidth)
	}
}

private var playerItemContext = 0

struct VideoPlayerViewWrapped: UIViewControllerRepresentable {
	@AppStorage("DesiredQuality") var desiredQuality: String = ""
	@ObservedObject var viewModel: VideoViewModel
	@Environment(\.managedObjectContext) var managedObjectContext
	
	let content: CdnDeliveryV2Response
	let beginningWatchTime: Double
	
	let logger: Logger = {
		var logger = Wasserflug.logger
		logger[metadataKey: "class"] = "\(Self.Type.self)"
		return logger
	}()
	
	func makeUIViewController(context: Context) -> ExtendedAVPlayerViewController {
		let vc = ExtendedAVPlayerViewController()
		vc.delegate = context.coordinator
		let playerItem = viewModel.createAVPlayerItem(desiredQuality: desiredQuality)
		if beginningWatchTime > 0.0, beginningWatchTime < 1.0 {
			let totalSeconds = viewModel.videoAttachment.duration
			let percentageOfTotal = beginningWatchTime
			let seekToSeconds = totalSeconds * percentageOfTotal
			let newCMTime = CMTime(seconds: seekToSeconds, preferredTimescale: 1)
			playerItem.seek(to: newCMTime, completionHandler: nil)
		}
		vc.player = AVPlayer(playerItem: playerItem)
		vc.player?.addObserver(context.coordinator, forKeyPath: #keyPath(AVPlayer.rate), context: nil)
		vc.player?.play() // Needs to play when it first appears.
		return vc
	}
	
	func updateUIViewController(_ uiViewController: ExtendedAVPlayerViewController, context: Context) {}
	
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
		
		override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
			guard let player = object as? AVPlayer else {
				return;
			}
			if keyPath != #keyPath(AVPlayer.rate) {
				return;
			}
			let fetchRequest = WatchProgress.fetchRequest()
			let totalDurationSeconds = parent.viewModel.videoAttachment.duration
			let blogPostId = parent.viewModel.contentPost.id
			let videoId = parent.viewModel.videoAttachment.id
			let progress: Double
			if let lastPlayerItem = player.currentItem {
				progress = Double(lastPlayerItem.currentTime().seconds) / totalDurationSeconds
			} else {
				progress = 0.0
			}
			
			fetchRequest.predicate = NSPredicate(format: "blogPostId = %@ and videoId = %@", blogPostId, videoId)
			
			parent.logger.notice("Attempting to record watch progress for a video.", metadata: [
				"blogPostId": "\(blogPostId)",
				"videoId": "\(videoId)",
				"totalDurationSeconds": "\(totalDurationSeconds)",
				"progress": "\(progress)",
			])
			
			if let fetchResult = (try? parent.managedObjectContext.fetch(fetchRequest))?.first {
				parent.logger.info("Did find previous watchProgress. Will mutate with new progress.", metadata: [
					"previous": "\(String(reflecting: fetchResult))",
				])
				fetchResult.progress = progress
			} else {
				parent.logger.info("No previous watchProgress found. Will create new WatchProgress entity.")
				let newWatchProgress = WatchProgress(context: parent.managedObjectContext)
				newWatchProgress.blogPostId = blogPostId
				newWatchProgress.videoId = videoId
				newWatchProgress.progress = progress
			}
			
			do {
				try parent.managedObjectContext.save()
				parent.logger.info("Successfully saved watch progress for \(blogPostId) \(videoId)")
			} catch {
				parent.logger.error("Error saving watch progress for for \(blogPostId) \(videoId): \(String(reflecting: error))")
				// Otherwise, this has minimal impact on the user of this application.
				// No need to further handle the error.
			}
			
			if player.rate > 0.0 {
				// Playback started
			} else {
				// Playback stopped
			}
		}
	}
}

class ExtendedAVPlayerViewController: AVPlayerViewController {
	var isStatusBarHidden: Bool = false
	
	override var prefersStatusBarHidden: Bool {
		return isStatusBarHidden
	}
}

// struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerView()
//    }
// }
