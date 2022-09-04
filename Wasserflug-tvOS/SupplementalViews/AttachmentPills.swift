import SwiftUI

struct AttachmentPill: View {
	let text: String
	
	var body: some View {
		Text(text)
			.padding([.all], 5)
			.foregroundColor(.white)
			.background(.gray)
			.cornerRadius(10)
	}
}

struct AttachmentPill_Previews: PreviewProvider {
	static var previews: some View {
		AttachmentPill(text: "Video")
	}
}
