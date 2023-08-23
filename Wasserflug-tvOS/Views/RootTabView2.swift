import SwiftUI
import CoreData
import GameController
import FloatplaneAPIClient
import DebouncedOnChange

struct RootTabView2: View {
	
	enum SideBarState: Equatable, CaseIterable {
		case collapsed
		case expanded
	}
	
	enum TabSelection: Hashable {
		case home
		case creator(String)
		case channel(String)
		case settings
		
		var isCreator: Bool {
			switch self {
			case .creator: return true
			default: return false
			}
		}
	}
	
	enum ScrollViewPosition: Hashable {
		case beginning
		case middle
		case end
	}
	
	@EnvironmentObject var userInfo: UserInfo
	@Environment(\.fpApiService) var fpApiService
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.scenePhase) var scenePhase
	
	@State var fpFrontendSocket: FPFrontendSocket
	let fixedWidth: CGFloat = 170
	@State var tabSelection: TabSelection = .home
	@State var state: SideBarState = .expanded
	@State var scrollViewFrameHeight = 1000.0
	@State var scrollViewPosition = ScrollViewPosition.beginning
	
	@FocusState var menuIsFocused: Bool
	@FocusState var contentIsFocused: Bool
	@FocusState var focusHackIsFocused: Bool
	@Namespace var menuFocusNamespace
	@Namespace var contentFocusNamespace
	@FocusState var focusedItem: TabSelection?
	
	var body: some View {
		HStack(spacing: 0) {
			sideBarView
				.zIndex(2)
				.accessibilityElement(children: .contain)
				.accessibilityLabel("Navigation sidebar")
			contentView
				.zIndex(1)
				.accessibilityElement(children: .contain)
				.accessibilityLabel("Main content")
				.disabled(state == .expanded)
				.overlay {
					if state == .expanded {
						Rectangle()
							.fill(Color.black.opacity(0.2))
					}
				}
		}
		.overlay(alignment: .trailing, content: {
			if state == .expanded {
				Rectangle()
					.fill(.clear)
					.frame(maxWidth: 50, maxHeight: .infinity)
					.focusable(true)
					.focused($focusHackIsFocused)
			}
		})
		.ignoresSafeArea()
		.onFirstAppear {
			menuIsFocused = true
		}
		.onChange(of: focusHackIsFocused, perform: { isFocused in
			if isFocused {
				focusHackIsFocused = false
				contentIsFocused = true
			}
		})
		.onChange(of: tabSelection) { tabSelection in
			switch tabSelection {
			case .home:
				UIAccessibility.post(notification: .announcement, argument: "Switched to home screen")
			case let .creator(creatorId):
				if let creator = self.userInfo.creators[creatorId] {
					UIAccessibility.post(notification: .announcement, argument: "Switched to creator \(creator.title)")
				}
			case let .channel(channelId):
				if let channel = self.userInfo.creators.values.flatMap(\.channels).first(where: { $0.id == channelId }) {
					UIAccessibility.post(notification: .announcement, argument: "Switched to channel \(channel.title)")
				}
			case .settings:
				UIAccessibility.post(notification: .announcement, argument: "Switched to settings screen")
			}
		}
		.fpSocketControlSocket(fpFrontendSocket, on: [.onAppear, .onSceneActive, .onSceneInactive, .onSceneBackground])
	}
	
	var contentView: some View {
		contentBody
			.frame(maxWidth: .infinity)
			.focusSection()
			.focusScope(contentFocusNamespace)
			.focused($contentIsFocused)
			.onExitCommand(perform: {
				if state == .collapsed {
					withAnimation {
						menuIsFocused = true
					}
				}
			})
	}
	
	var contentBody: some View {
		ZStack {
			HomeView(viewModel: HomeViewModel(userInfo: userInfo, fpApiService: fpApiService, managedObjectContext: managedObjectContext))
				.customAppear(tabSelection == .home ? .appear : .disappear)
				.opacity(tabSelection == .home ? 1 : 0)
				.accessibilityHidden(tabSelection == .home ? false : true)

			ForEach(userInfo.creatorsInOrder, id: \.0.id) { creator, creatorOwner in
				CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, managedObjectContext: managedObjectContext, creatorOrChannel: creator, creatorOwner: creatorOwner))
					.customAppear(tabSelection == .creator(creator.id) ? .appear : .disappear)
					.opacity(tabSelection == .creator(creator.id) ? 1 : 0)
					.accessibilityHidden(tabSelection == .creator(creator.id) ? false : true)
				
				ForEach(creator.channels, id: \.id) { channel in
					CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, managedObjectContext: managedObjectContext, creatorOrChannel: channel, creatorOwner: creatorOwner))
						.customAppear(tabSelection == .channel(channel.id) ? .appear : .disappear)
						.opacity(tabSelection == .channel(channel.id) ? 1 : 0)
						.accessibilityHidden(tabSelection == .channel(channel.id) ? false : true)
				}
			}

			SettingsView()
				.customAppear(tabSelection == .settings ? .appear : .disappear)
				.opacity(tabSelection == .settings ? 1 : 0)
				.accessibilityHidden(tabSelection == .settings ? false : true)
		}
	}
	
	var sideBarView: some View {
		sideBar
			.fixedSize(horizontal: true, vertical: false)
			.frame(width: fixedWidth + (tabSelection.isCreator ? 30 : 0), alignment: .leading)
			// These deal with focus management and focus transitions
			.focusSection()
			.focusScope(menuFocusNamespace)
			.focused($menuIsFocused)
			.onChange(of: menuIsFocused, perform: { menuIsFocused in
				if menuIsFocused {
					withAnimation {
						state = .expanded
						focusedItem = tabSelection
					}
				} else {
					withAnimation {
						state = .collapsed
					}
				}
			})
	}
	
	var sideBar: some View {
		let showMenu = state == .expanded
		return VStack(spacing: 0) {
			VStack {
				Button(action: {
					withAnimation {
						tabSelection = .home
					}
				}, label: {
					HStack(spacing: 0) {
						Image("wasserflug-logo")
							.resizable()
							.renderingMode(.template)
							.scaledToFit()
							.frame(width: 120)
						if showMenu {
							Text("Home")
								.font(Font.headline)
								.lineLimit(1)
								.fixedSize()
								.padding([.leading])
						}
					}
				})
				.buttonStyle(.plain)
				.focused($focusedItem, equals: TabSelection.home)
				.prefersDefaultFocus(in: menuFocusNamespace)
				.accessibilityLabel("Home view")
				.accessibilityHint("Go to the home screen to view all subscription content")
			}
			.padding([.top, .bottom], 30)
			.padding([.leading, .trailing], showMenu ? 50 : 0)
			
			ScrollViewReader { proxy in
				ScrollView {
					VStack {
						ForEach(userInfo.creatorsInOrder, id: \.0.id) { creator, creatorOwner in
							button(forCreator: creator)
								.id(TabSelection.creator(creator.id))
								.focused($focusedItem, equals: TabSelection.creator(creator.id))
								.onChange(of: focusedItem, debounceTime: .seconds(0.5), perform: { focusedItem in
									if focusedItem == .creator(creator.id) {
										proxy.scrollTo(focusedItem)
									}
								})
							
							ForEach(creator.channels, id: \.id) { channel in
								button(forChannel: channel, creator: creator)
									.id(TabSelection.channel(channel.id))
									.focused($focusedItem, equals: TabSelection.channel(channel.id))
									.onChange(of: focusedItem, debounceTime: .seconds(0.5), perform: { focusedItem in
										if focusedItem == .channel(channel.id) {
											proxy.scrollTo(focusedItem)
										}
									})
							}
						}
					}
					.background(GeometryReader {
						let scrollDistance = -$0.frame(in: .named("scroll")).origin.y
						let scrollContentHeight = $0.frame(in: .named("scroll")).size.height
						let position: ScrollViewPosition = scrollDistance <= 0.0 ? .beginning : scrollDistance >= scrollContentHeight - scrollViewFrameHeight ? .end : .middle
						if position != self.scrollViewPosition {
							let _ = Task { @MainActor in
								self.scrollViewPosition = position
							}
						}
					})
					.padding([.leading, .trailing], 30)
					.padding([.top, .bottom], 15)
				}
				.coordinateSpace(name: "scroll")
				.background(GeometryReader { geoProxy in
					let scrollViewFrameHeight = geoProxy.size.height
					if self.scrollViewFrameHeight != scrollViewFrameHeight {
						let _ = Task { @MainActor in
							self.scrollViewFrameHeight = scrollViewFrameHeight
						}
					}
					EmptyView()
				})
				.innerShadow(color: .black, radius: 30, edges: !showMenu ? [] : scrollViewPosition == .beginning ? .bottom : scrollViewPosition == .end ? .top : [.top, .bottom])
			}
			
			VStack {
				Button(action: {
					withAnimation {
						tabSelection = .settings
					}
				}, label: {
					HStack(spacing: 0) {
						Image(systemName: "gear")
						if showMenu {
							Text("Settings")
								.lineLimit(1)
								.fixedSize()
								.padding([.leading])
						}
					}
				})
				.buttonStyle(.plain)
				.animation(.linear, value: showMenu)
				.focused($focusedItem, equals: TabSelection.settings)
				.padding([.bottom], 20)
				.accessibilityLabel("Wasserflug Settings")
				.accessibilityHint("Go to the settings page")
			}
			.padding([.top, .bottom], 30)
			.padding([.leading, .trailing], showMenu ? 50 : 0)
		}
		.background(FPColors.sidebarBlue)
		.environment(\.colorScheme, .dark)
	}
	
	func button(forCreator creator: CreatorModelV3) -> some View {
		let showMenu = state == .expanded
		let imageSize: CGFloat = 75
		let indent: CGFloat = 0
		let isSelected = tabSelection == .creator(creator.id)
		return Button(action: {
			withAnimation {
				tabSelection = .creator(creator.id)
			}
		}, label: {
			HStack(spacing: 0) {
				AsyncImage(url: (creator.icon as ImageModelShared?).bestImage(for: CGSize(width: imageSize, height: imageSize))) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: imageSize, height: imageSize)
				.cornerRadius(imageSize)
				.padding([.leading], indent)
				if showMenu {
					Text(creator.title)
						.lineLimit(1)
						.fixedSize()
						.padding([.leading])
					Spacer()
					if !creator.channels.isEmpty {
						Image(systemName: "chevron.down")
					}
				}
			}
			.padding(15)
			.background(isSelected ? VisualEffectView(effect: UIBlurEffect(style: .light)) : nil)
			.animation(.spring(), value: showMenu)
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Creator \(creator.title)")
		})
		.background(.clear)
		.buttonStyle(.card)
	}
	
	func button(forChannel channel: ChannelModel, creator: CreatorModelV3) -> some View {
		let showMenu = state == .expanded
		let imageSize: CGFloat = 50
		let indent: CGFloat = showMenu ? 40 : 0
		let isSelected = tabSelection == .channel(channel.id)
		return Button(action: {
			withAnimation {
				tabSelection = .channel(channel.id)
			}
		}, label: {
			HStack(spacing: 0) {
				AsyncImage(url: (channel.icon as ImageModelShared?).bestImage(for: CGSize(width: imageSize, height: imageSize))) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: imageSize, height: imageSize)
				.cornerRadius(imageSize)
				.padding([.leading], indent)
				if showMenu {
					Text(channel.title)
						.lineLimit(1)
						.fixedSize()
						.padding([.leading])
					Spacer()
				}
			}
			.padding(15)
			.background(isSelected ? VisualEffectView(effect: UIBlurEffect(style: .light)) : nil)
			.animation(.spring(), value: showMenu)
			.accessibilityElement(children: .ignore)
			.accessibilityLabel("Channel \(channel.title)")
		})
		.background(.clear)
		.buttonStyle(.card)
	}
}

struct RootTabView2_Previews: PreviewProvider {
	static var previews: some View {
		RootTabView2(fpFrontendSocket: MockFPFrontendSocket(sailsSid: ""))
			.environmentObject(MockData.userInfo)
			.environment(\.fpApiService, MockFPAPIService())
	}
}
