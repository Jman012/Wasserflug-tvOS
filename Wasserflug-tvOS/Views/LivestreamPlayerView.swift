import Foundation
import SwiftUI
import AVKit
import Combine
import FloatplaneAPIClient

struct LivestreamPlayerView: UIViewControllerRepresentable {
	@ObservedObject var viewModel: LivestreamViewModel
	
	func makeUIViewController(context: Context) -> AVPlayerViewController {
		let vc = AVPlayerViewController()
		vc.player = AVPlayer(playerItem: viewModel.createAVPlayerItem())
		return vc
	}

	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
		if let player = uiViewController.player, viewModel.shouldUpdatePlayer {
			viewModel.shouldUpdatePlayer = false
			let newPlayerItem = viewModel.createAVPlayerItem()
			player.replaceCurrentItem(with: newPlayerItem)
			player.play()
		}
	}
}
