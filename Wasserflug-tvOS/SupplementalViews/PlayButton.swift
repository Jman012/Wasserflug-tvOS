import SwiftUI

struct PlayButton: View {
	
	enum Size {
		case `default`
		case small
		
		var frameWidth: CGFloat {
			switch self {
			case .default:
				return 160.0
			case .small:
				return 80.0
			}
		}
		
		var frameHeight: CGFloat {
			switch self {
			case .default:
				return 100.0
			case .small:
				return 50.0
			}
		}
		
		var imageSize: CGFloat {
			switch self {
			case .default:
				return 50.0
			case .small:
				return 25.0
			}
		}
	}
	
	let size: Size
	let action: () -> Void
	
	var body: some View {
		Button(action: self.action) {
			ZStack {
				Rectangle()
					.fill(Color(.sRGB, red: 0.0/256.0, green: 160.0/256.0, blue: 236.0/256.0, opacity: 0.70))
					.cornerRadius(10.0)
					.frame(width: size.frameWidth, height: size.frameHeight)
				Image(systemName: "play.fill")
					.renderingMode(.template)
					.foregroundColor(.white)
					.font(.system(size: size.imageSize))
			}
		}
			.buttonStyle(.card)
			.onPlayPauseCommand(perform: self.action)
	}
}

struct PlayButton_Previews: PreviewProvider {
	static var previews: some View {
		PlayButton(size: .small, action: { })
			.frame(width: 200, height: 300)
	}
}
