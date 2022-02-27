import Foundation
import SwiftUI
import AVKit
import Combine
import FloatplaneAPIClient
import Logging

struct VideoPlayerView: UIViewControllerRepresentable {
	@AppStorage("DesiredQuality") var desiredQuality: String = ""
	@ObservedObject var viewModel: VideoViewModel
	let content: CdnDeliveryV2Response
	
	let logger: Logger = {
		var logger = Wasserflug_tvOSApp.logger
		logger[metadataKey: "class"] = "\(Self.Type.self)"
		return logger
	}()
	
	func makeUIViewController(context: Context) -> AVPlayerViewController {
		logger.notice("Creating AVPlayerViewController instance for playback.", metadata: [
			"videoId": "\(viewModel.videoAttachment.id)",
		])
		let vc = AVPlayerViewController()
		vc.transportBarCustomMenuItems = [createQualityAction(content: content)]
		vc.player = AVPlayer(playerItem: viewModel.createAVPlayerItem(desiredQuality: desiredQuality))
		return vc
	}

	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
		
		if let player = uiViewController.player {
			let newPlayerItem = viewModel.createAVPlayerItem(desiredQuality: desiredQuality)
			let lastPlayerItem = player.currentItem
			
			logger.notice("Updating the AVPlayerViewController's AVPlayerItem with the latest video URL and quality.")
			
			if let lastPlayerItem = lastPlayerItem {
				let time = lastPlayerItem.currentTime()
				logger.notice("User was in the middle of the video before this update. Seeking to the previous timestamp of \(time.seconds).")
				newPlayerItem.seek(to: time, completionHandler: nil)
			}
			
			player.replaceCurrentItem(with: newPlayerItem)
			player.play()
		} else {
			logger.warning("While updating AVPlayerViewController, no AVPlayer was found. Skipping the update of the AVPlayerItem.")
		}
		
		
		if let qualityMenu = uiViewController.transportBarCustomMenuItems.first(where: { $0.title == "Resolution" }) as? UIMenu {
			if let qualitySubMenu = qualityMenu.children.first(where: { $0.title == "Resolution" }) as? UIMenu {
				logger.debug("Resetting resolution picker to last user-selected resolution of \(self.desiredQuality).")
				for case let option as UIAction in qualitySubMenu.children {
					option.state = .off
					if option.identifier == UIAction.Identifier(desiredQuality) {
						option.state = .on
					}
				}
			}
		}
	}
	
	static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
		Wasserflug_tvOSApp.logger.notice("Dismantling AVPlayerViewController.")
		if let player = uiViewController.player {
			Wasserflug_tvOSApp.logger.notice("Pausing AVPlayerViewController's AVPlayer before dismantling.")
			player.pause()
		}
	}
	
	func createQualityAction(content: CdnDeliveryV2Response) -> UIMenu {
		let sparkleTvImage = UIImage(systemName: "sparkles.tv")
		let resolutions = content.resource.data.qualityLevels!
			.sorted(by: { $0.order < $1.order })
			.map({ (qualityLevel) -> UIAction in
				return UIAction(title: qualityLevel.label, identifier: UIAction.Identifier(qualityLevel.name), handler: { _ in
					UserDefaults.standard.set(qualityLevel.name, forKey: "DesiredQuality")
				})
		})
		let submenu = UIMenu(title: "Resolution", options: [.displayInline, .singleSelection], children: resolutions)
		let menu = UIMenu(title: "Resolution", image: sparkleTvImage, children: [submenu])
		return menu
	}
	
}
