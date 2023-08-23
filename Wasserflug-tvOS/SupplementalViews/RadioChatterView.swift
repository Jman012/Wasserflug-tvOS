import SwiftUI
import FloatplaneAPIAsync
import BigNumber

struct RadioChatterView: View {
	/// BigNumber/BitInt calculations are slow, so cache the results.
	static var usernameHashCache: [String: Int] = [:]
	
	let radioChatter: RadioChatter
	
	func hash(username: String) -> Int64 {
		var hashCode: BInt = 0
		for c in username.utf8 {
			hashCode = BInt(c) + ((hashCode << BInt(5)) - hashCode)
		}
		hashCode %= BInt((1 << 53) - 1)
		if let limb = hashCode.rawValue.limbs.first, limb <= Int64.max {
			return Int64(limb)
		} else {
			// This is a failsafe. This should never execute.
			return 0
		}
	}

	func color(for username: String) -> Color {
		let bound = Int64(FPColors.UsernameColors.all.count)
		
		// Use cache when possible
		if let hash = RadioChatterView.usernameHashCache[username] {
			return FPColors.UsernameColors.all[hash]
		}
		
		// Calculate and populate the cache if needed
		let hash = Int(((hash(username: username) % bound) + bound) % bound)
		RadioChatterView.usernameHashCache[username] = hash
		return FPColors.UsernameColors.all[Int(hash)]
	}
	
	var body: some View {
		HStack {
			let text = Text(radioChatter.username).foregroundColor(color(for: radioChatter.username)).bold() + Text("    ") + Text(verbatim: radioChatter.message)
			
			text
				.font(Font.system(size: 20))
			Spacer(minLength: 0)
		}
		.padding([.leading, .trailing], 10)
	}
}

struct RadioChatterView_Previews: PreviewProvider {
	static var previews: some View {
		VStack(alignment: .leading) {
			ForEach(["jamamp", "JiMb0", "jland", "Pjay95", "Venrik_Streea", "CrustyTrombone", "Digitalb11", "rorky"], id: \.self) { username in
				RadioChatterView(radioChatter: .init(
					channel: "",
					emotes: nil,
					id: "1",
					message: "this is a very long message that tests out multi-line behavior",
					success: nil,
					userGUID: "",
					username: username,
					userType: .normal))
			}
		}
		.background(.regularMaterial)
		.ignoresSafeArea()
		.previewLayout(.fixed(width: 480, height: 700))
	}
}
