import SwiftUI

struct LivestreamView<ChatClient>: View where ChatClient: FPChatClient {
	@Environment(\.scenePhase) var scenePhase
	@StateObject var viewModel: LivestreamViewModel
	///	@StateObject var fpChatSocket: FPChatSocket
	@StateObject var fpChatClient: ChatClient
	
	@State var chatState: RootTabView2.SideBarState = .expanded
	@State var shouldPlay = true
	
	var body: some View {
		VStack {
			switch viewModel.state {
			case .idle:
				ProgressView().onAppear(perform: {
					viewModel.load()
				})
			case .loading:
				ProgressView()
			case let .failed(error):
				ErrorView(error: error, tryAgainText: "Refresh", tryAgainHandler: {
					viewModel.state = .idle
				})
			case let .loaded((creator, _, _)):
				GeometryReader { geoProxy in
					HStack(spacing: 0) {
						ZStack {
							if !viewModel.isLive {
								ZStack {
									AsyncImage(url: URL(string: creator.liveStream?.offline.thumbnail?.path ?? ""), content: { image in
										image
											.resizable()
											.scaledToFit()
									}, placeholder: {
										ProgressView()
									})
									
									VStack {
										Text("This channel is offline")
											.font(.title2)
											.fontWeight(.semibold)
										Text("Hang around and the stream will start automatically when it goes live!")
											.font(.callout)
									}
									.padding(30)
									.background(.regularMaterial)
									.cornerRadius(10)
								}
								.frame(maxWidth: .infinity, maxHeight: .infinity)
								.environment(\.colorScheme, .dark)
								.background(.black)
							} else {
								LivestreamPlayerView(viewModel: viewModel, chatSidebarState: self.chatState, toggleChatSidebar: {
									withAnimation {
										self.chatState = .expanded
									}
								}, shouldPlay: $shouldPlay)
									.onAppear {
										UIApplication.shared.isIdleTimerDisabled = true
									}.onDisappear {
										UIApplication.shared.isIdleTimerDisabled = false
									}
							}
						}
						.overlay(alignment: .topTrailing, content: {
							if chatState == .collapsed && !viewModel.isLive {
								Button(action: {
									withAnimation {
										chatState = .expanded
									}
								}, label: {
									Image(systemName: "arrow.left.to.line")
								})
								.buttonStyle(LivestreamCircleButtonStyle())
								.padding()
							}
						})
						
						if chatState == .expanded {
							Divider()
							
							LivestreamChatSidebar(fpChatClient: fpChatClient, onCollapse: {
								withAnimation {
									chatState = .collapsed
								}
							}, onConnect: {
								fpChatClient.connect()
							}, shouldPlay: $shouldPlay)
								.frame(maxWidth: geoProxy.size.width * 0.25)
								.transition(.move(edge: .trailing))
						}
					}
				}
				.ignoresSafeArea()
			}
		}
		.onAppear {
			viewModel.startLoadingLiveStatus()
		}.onDisappear {
			viewModel.stopLoadingLiveStatus()
		}.onChange(of: scenePhase, perform: { phase in
			switch phase {
			case .active:
				viewModel.loadLiveStatus()
			case .inactive, .background:
				viewModel.stopLoadingLiveStatus()
			@unknown default:
				break
			}
		})
		.fpSocketControlSocket(fpChatClient, on: [.onAppear, .onDisappear])
	}
}

struct LivestreamView_Previews: PreviewProvider {
	static var previews: some View {
		ForEach(RootTabView2.SideBarState.allCases, id: \.self) {
			LivestreamView(
				viewModel: MockOfflineLivestreamViewModel(),
				fpChatClient: MockFPChatClient.withChatter,
				chatState: $0
			)
			.previewDisplayName("\($0)")
		}
	}
}
