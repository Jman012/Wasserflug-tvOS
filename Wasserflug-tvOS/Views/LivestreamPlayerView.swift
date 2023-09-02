import Foundation
import SwiftUI
import AVKit
import Combine
import FloatplaneAPIClient

struct LivestreamPlayerView: UIViewControllerRepresentable {
	@ObservedObject var viewModel: LivestreamViewModel
	let chatSidebarState: RootTabView2.SideBarState
	let toggleChatSidebar: () -> Void
	@Binding var shouldPlay: Bool
	
	func makeUIViewController(context: Context) -> AVPlayerViewController {
		let vc = AVPlayerViewController()
		vc.player = AVPlayer(playerItem: viewModel.createAVPlayerItem())
		return vc
	}

	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
		if let player = uiViewController.player {
			if viewModel.shouldUpdatePlayer {
				viewModel.shouldUpdatePlayer = false
				let newPlayerItem = viewModel.createAVPlayerItem()
				player.replaceCurrentItem(with: newPlayerItem)
			}
			
			if shouldPlay {
				player.play()
			} else {
				player.pause()
			}
		}
		
		if chatSidebarState == .collapsed {
			uiViewController.view.isUserInteractionEnabled = true
			uiViewController.transportBarCustomMenuItems = [
				createChatExpandAction(),
			]
		} else {
			uiViewController.view.isUserInteractionEnabled = false
			uiViewController.transportBarCustomMenuItems = []
		}
	}
	
	func createChatExpandAction() -> UIAction {
		let image = UIImage(systemName: "arrow.left.to.line")
		let action = UIAction(image: image, handler: { _ in self.toggleChatSidebar() })
		return action
	}
}
