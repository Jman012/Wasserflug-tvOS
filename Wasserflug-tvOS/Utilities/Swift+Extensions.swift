import Foundation

private let accessibilityVideoDurationFormatter: DateComponentsFormatter = {
	let f = DateComponentsFormatter()
	f.unitsStyle = .spellOut
	f.allowedUnits = [.hour, .minute, .second]
	return f
}()

extension TimeInterval {
	var floatplaneTimestamp: String {
		if hour == 0 {
			return minuteSecond
		} else {
			return hourMinuteSecond
		}
	}

	var accessibleFloatplanetimestamp: String {
		return accessibilityVideoDurationFormatter.string(from: Date.now, to: Date.now.addingTimeInterval(self)) ?? floatplaneTimestamp
	}

	var hourMinuteSecond: String {
		String(format:"%d:%02d:%02d", hour, minute, second)
	}

	var minuteSecond: String {
		String(format:"%d:%02d", minute, second)
	}

	var hour: Int {
		Int((self/3600).truncatingRemainder(dividingBy: 3600))
	}

	var minute: Int {
		Int((self/60).truncatingRemainder(dividingBy: 60))
	}

	var second: Int {
		Int(truncatingRemainder(dividingBy: 60))
	}

	var millisecond: Int {
		Int((self*1000).truncatingRemainder(dividingBy: 1000))
	}
}
