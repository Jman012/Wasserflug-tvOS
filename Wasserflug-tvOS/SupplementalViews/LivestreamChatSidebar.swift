import SwiftUI

struct LivestreamChatSidebar: View {
	let fpChatSocket: FPChatSocket
	let onCollapse: () -> Void
	let onConnect: () -> Void
	
	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 20) {
				Text("Live Chat")
					.bold()
					.foregroundColor(.white)
				Spacer()
				Button(action: {
					onCollapse()
				}, label: {
					Image(systemName: "arrow.right.to.line")
				})
				Button(action: {
					
				}, label: {
					Image(systemName: "gearshape.fill")
				})
			}
			.buttonStyle(LivestreamCircleButtonStyle())
			.padding()
			.background(FPColors.LiveChat.headerBg)
			
			ScrollViewReader { scrollProxy in
				ScrollView {
					VStack(spacing: 5) {
						ForEach(fpChatSocket.radioChatter) { radioChatter in
							Divider()
							RadioChatterView(radioChatter: radioChatter)
						}
					}
					.padding([.top], 10)
					
					EmptyView()
						.id("bottom")
				}
				.innerShadow(color: .gray, radius: 10, edges: .top)
				.onChange(of: fpChatSocket.radioChatter, perform: { _ in
					scrollProxy.scrollTo("bottom", anchor: .bottom)
				})
			}
		}
		.overlay(content: {
			if fpChatSocket.connectionError != nil || fpChatSocket.status != .joinedLivestreamFrequency {
				VStack {
					if fpChatSocket.connectionError != nil {
						Text("Error connecting")
						Button(action: {
							onConnect()
						}, label: {
							Text("Try Again")
						})
					} else if fpChatSocket.status == .notConnected {
						Text("Not connected")
						Button(action: {
							onConnect()
						}, label: {
							Text("Connect")
						})
					} else if fpChatSocket.status == .waitingToReconnect {
						ProgressView()
						Text("Attempting to reconnect")
					} else if fpChatSocket.status != .joinedLivestreamFrequency {
						ProgressView()
						Text("Connecting")
					}
				}
				.padding(30)
				.background(.thinMaterial)
				.cornerRadius(10)
			}
		})
	}
}

struct LivestreamCircleButtonStyle: ButtonStyle {
	@ViewBuilder func makeBody(configuration: ButtonStyleConfiguration) -> some View {
		TheButton(configuration: configuration)
	}
	
	struct TheButton: View {
		@Environment(\.isFocused) var focused: Bool
		
		let configuration: ButtonStyle.Configuration
		
		var body: some View {
			configuration.label
				.environment(\.colorScheme, .dark)
				.font(.system(size: 24))
				.bold()
				.padding(10)
				.background(Circle().fill(focused ? FPColors.LiveChat.buttonBgFocused : FPColors.LiveChat.buttonBg))
				.scaleEffect(configuration.isPressed ? 0.9 : focused ? 1.2 : 1.0)
				.animation(.linear(duration: 0.2), value: configuration.isPressed)
		}
	}
}

struct LivestreamChatSidebar_Previews: PreviewProvider {
	static var previews: some View {
		ForEach(MockFPChatSocket.all, id: \.self) {
			LivestreamChatSidebar(fpChatSocket: $0, onCollapse: {}, onConnect: {})
				.ignoresSafeArea()
				.previewLayout(.fixed(width: 500, height: 1000))
				.previewDisplayName($0.display)
		}
	}
}
