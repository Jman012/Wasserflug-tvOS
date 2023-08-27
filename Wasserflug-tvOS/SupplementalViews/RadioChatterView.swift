import SwiftUI
import UIKit
import FloatplaneAPIAsync

struct RadioChatterView: View {
	let radioChatter: RenderedRadioChatter
	
	var body: some View {
		HStack {
			radioChatter.text
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
				
				let rc = RadioChatter(
					channel: "",
					emotes: nil,
					id: "1",
					message: "this is a very long message that tests out multi-line behavior and mentions @jamamp and @someone for testing",
					success: nil,
					userGUID: "",
					username: username,
					userType: .normal)
				
				RadioChatterView(radioChatter: .init(
					radioChatter: rc,
					loadedEmotes: [:],
					selfUsername: "jamamp"))
			}
		}
		.background(.regularMaterial)
		.ignoresSafeArea()
		.previewLayout(.fixed(width: 480, height: 700))
	}
}
