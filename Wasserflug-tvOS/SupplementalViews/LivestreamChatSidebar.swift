import SwiftUI

struct LivestreamChatSidebar<ChatClient>: View where ChatClient: FPChatClient {
	let fpChatClient: ChatClient
	let onCollapse: () -> Void
	let onConnect: () -> Void
	@Binding var shouldPlay: Bool
	
	@FocusState private var collapseButtonIsFocused
	
	var body: some View {
		VStack(spacing: 0) {
			// Header
			HStack(spacing: 20) {
				Text("Live Chat")
					.bold()
					.foregroundColor(.white) // Always white, since both bg colors are dark regardless of color scheme
				
				Spacer()
				
				Button(action: {
					shouldPlay.toggle()
				}, label: {
					Image(systemName: shouldPlay ? "pause.fill" : "play.fill")
				})
				
				Button(action: {
					onCollapse()
				}, label: {
					Text(Image(systemName: "arrow.right.to.line"))
						.fontWeight(.some(.black))
				})
				.focused($collapseButtonIsFocused)
				.onAppear {
					collapseButtonIsFocused = true
				}
			}
			.buttonStyle(LivestreamCircleButtonStyle())
			.padding()
			.background(FPColors.LiveChat.headerBg)
			
			// Main chat scroll view
			ScrollViewReader { scrollProxy in
				ScrollView {
					VStack(spacing: 5) {
						ForEach(fpChatClient.radioChatter) { radioChatter in
							RadioChatterView(radioChatter: radioChatter)
							Divider()
								.id(radioChatter.id)
						}
					}
					.padding([.top, .bottom], 10)
				}
				.innerShadow(color: .gray, radius: 10, edges: .top)
				.onChange(of: fpChatClient.radioChatter, perform: { allChatter in
					// Scroll to bottom
					withAnimation(Animation.default.delay(0.01)) {
						if let last = allChatter.last {
							scrollProxy.scrollTo(last.id)
						}
					}
				})
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.overlay(content: {
				// Loading or error notification overlay
				if fpChatClient.status != .connected {
					VStack {
						VStack {
							if fpChatClient.status == .unexpectedlyDisconnected {
								Text("Error connecting")
								Button(action: {
									onConnect()
								}, label: {
									Text("Try Again")
								})
								.padding(30)
							} else if fpChatClient.status == .disconnectedBySelf {
								Text("Disconnected")
								Button(action: {
									onConnect()
								}, label: {
									Text("Reconnect")
								})
								.padding(30)
							} else if fpChatClient.status == .notConnected {
								Text("Not connected")
								Button(action: {
									onConnect()
								}, label: {
									Text("Connect")
								})
							} else if fpChatClient.status != .connected {
								ProgressView()
								Text("Connecting")
							}
						}
						.padding(30)
						.background(.thinMaterial)
						.cornerRadius(10)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.focusSection()
				}
			})
		}
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
	@State static var shouldPlayTrue = true
	@State static var shouldPlayFalse = false
	
	static var previews: some View {
		ForEach(MockFPChatClient.all, id: \.self) {
			LivestreamChatSidebar(fpChatClient: $0, onCollapse: {}, onConnect: {}, shouldPlay: Self.$shouldPlayTrue)
				.ignoresSafeArea()
				.previewLayout(.fixed(width: 500, height: 1000))
				.previewDisplayName($0.display)
		}
	}
}
