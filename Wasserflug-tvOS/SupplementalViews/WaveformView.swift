import SwiftUI
import Logging
import FloatplaneAPIClient

struct WaveformView: View {
	
	let waveform: AudioAttachmentModelWaveform
	let width: CGFloat
	let height: CGFloat
	
	let logger: Logger = {
		var logger = Wasserflug_tvOSApp.logger
		logger[metadataKey: "class"] = "\(Self.Type.self)"
		return logger
	}()
	
	private func compute() -> (CGFloat, Range<Int>, CGFloat, ArraySlice<Int>, CGFloat) {
		let range = 0..<(min(20, waveform.data.count))
		let data = waveform.data[range]
		let maxDataPoint = data.max() ?? 0
		// The max times the scale should equal the height.
		// max * scale = height
		// scale = height / max
		let spacing: CGFloat = 4
		let heightScale = height / CGFloat(maxDataPoint)
		let waveWidth = (width - (CGFloat(range.count - 1) * spacing)) / CGFloat(range.count)
		logger.debug("range=\(range), data=\(data), maxDataPoint=\(maxDataPoint), spacing=\(spacing), heightScale=\(heightScale), waveWidth=\(waveWidth), width=\(width), height=\(height)")
		return (spacing, range, waveWidth, data, heightScale)
	}
	
	var body: some View {
		let (spacing, range, waveWidth, data, heightScale) = compute()
		HStack(spacing: spacing) {
			ForEach(range, id: \.self) {
				Rectangle()
					.fill(.white)
					.frame(width: waveWidth, height: CGFloat(data[$0]) * heightScale)
					.cornerRadius(waveWidth)
			}
		}
	}
}

struct WaveformView_Previews: PreviewProvider {
	static var previews: some View {
		WaveformView(waveform: MockData.getBlogPost.audioAttachments!.first!.waveform, width: 192, height: 108)
			.previewLayout(.fixed(width: 192, height: 108))
	}
}
