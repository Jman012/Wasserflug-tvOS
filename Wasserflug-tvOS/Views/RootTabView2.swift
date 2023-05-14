import SwiftUI
import CoreData
import GameController
import FloatplaneAPIClient
import CachedAsyncImage
import DebouncedOnChange

struct RootTabView2: View {
	
	enum SideBarState {
		case collapsed
		case expanded
	}
	
	enum TabSelection: Hashable {
		case home
		case creator(String)
		case settings
	}
	
	@EnvironmentObject var userInfo: UserInfo
	@Environment(\.fpApiService) var fpApiService
	
	let fixedWidth: CGFloat = 165
	@State var tabSelection: TabSelection? = nil
	@State var state: SideBarState = .collapsed
	
	@FocusState var menuIsFocused: Bool
	@FocusState var contentIsFocused: Bool
	@Namespace var menuFocusNamespace
	@Namespace var contentFocusNamespace
	@FocusState var focusedItem: TabSelection?
	
	var body: some View {
		HStack(spacing: 0) {
			sideBarView
				.zIndex(2)
			contentView
				.zIndex(1)
		}
		.onChange(of: tabSelection, perform: { _ in
//			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//				withAnimation {
//					contentIsFocused = true
//				}
//			})
		})
		.ignoresSafeArea()
		.onAppear {
			contentIsFocused = true
			tabSelection = .home
		}
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
	
//	var contentBody: some View {
//		ZStack {
//			switch tabSelection {
//			case .home:
//				HomeView(viewModel: HomeViewModel(userInfo: userInfo, fpApiService: fpApiService))
//			case let .creator(id):
//				if let (creator, creatorOwner) = userInfo.creatorsInOrder.first(where: { $0.0.id == id }) {
//					CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner), livestreamViewModel: LivestreamViewModel(fpApiService: fpApiService, creatorId: creator.id))
//				} else {
//					ErrorView(error: WasserflugError.creatorNotFound, tryAgainHandler: {})
//				}
//			case .settings:
//				SettingsView()
//			}
//		}
//	}
	
//	var contentBody: some View {
//		ZStack {
//			HomeView(viewModel: HomeViewModel(userInfo: userInfo, fpApiService: fpApiService))
//				.hide(tabSelection != .home)
//
//			ForEach(userInfo.creatorsInOrder, id: \.0.id) { (creator, creatorOwner) in
//				CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner), livestreamViewModel: LivestreamViewModel(fpApiService: fpApiService, creatorId: creator.id))
//					.hide(tabSelection != .creator(creator.id))
//			}
//
//			SettingsView()
//				.hide(tabSelection != .settings)
//		}
//	}
	
	var contentBody: some View {
		ZStack {
			HomeView(viewModel: HomeViewModel(userInfo: userInfo, fpApiService: fpApiService))
				.customAppear(tabSelection == .home ? .appear : .disappear)
				.opacity(tabSelection == .home ? 1 : 0)

			ForEach(userInfo.creatorsInOrder, id: \.0.id) { (creator, creatorOwner) in
				CreatorContentView(viewModel: CreatorContentViewModel(fpApiService: fpApiService, creator: creator, creatorOwner: creatorOwner), livestreamViewModel: LivestreamViewModel(fpApiService: fpApiService, creatorId: creator.id))
					.customAppear(tabSelection == .creator(creator.id) ? .appear : .disappear)
					.opacity(tabSelection == .creator(creator.id) ? 1 : 0)
			}

			SettingsView()
				.customAppear(tabSelection == .settings ? .appear : .disappear)
				.opacity(tabSelection == .settings ? 1 : 0)
		}
	}
	
	var sideBarView: some View {
		sideBar
			.fixedSize(horizontal: true, vertical: false)
			.frame(width: fixedWidth, alignment: .leading)
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
			// Manually move focus from sidebar to content on swipe right.
			// This is needed because the overlapping focusSections don't allow
			// for proper focus traversal.
			.onMoveCommand { direction in
				if menuIsFocused && direction == .right {
					withAnimation {
						contentIsFocused = true
					}
				}
			}
			// Same as above, but for swipes instead of arrow key/directional
			// move commands.
			.onAppear(perform: {
				guard let microGamepad = GCController.controllers().first?.microGamepad else {
					return
				}
				microGamepad.reportsAbsoluteDpadValues = true
				microGamepad.dpad.valueChangedHandler = { pad, x, y in
					let fingerDistanceFromSiriRemoteCenter: Float = 0.7
//					let swipeValues: String = "x: \(x), y: \(y), pad.left: \(pad.left), pad.right: \(pad.right), pad.down: \(pad.down), pad.up: \(pad.up), pad.xAxis: \(pad.xAxis), pad.yAxis: \(pad.yAxis)"
					if y > fingerDistanceFromSiriRemoteCenter {
//						print(">>> up \(swipeValues)")
					} else if y < -fingerDistanceFromSiriRemoteCenter {
//						print(">>> down \(swipeValues)")
					} else if x < -fingerDistanceFromSiriRemoteCenter {
//						print(">>> left \(swipeValues)")
					} else if x > fingerDistanceFromSiriRemoteCenter {
//						print(">>> right \(swipeValues)")
						if menuIsFocused {
							withAnimation {
								contentIsFocused = true
							}
						}
					} else {
						//print(">>> tap \(swipeValues)")
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
			}
			.padding([.top], 30)
			.padding([.leading, .trailing], showMenu ? 50 : 0)
			
			ScrollView {
				ScrollViewReader { proxy in
					VStack {
						ForEach(userInfo.creatorsInOrder, id: \.0.id) { (creator, creatorOwner) in
							button(for: creator)
								.id(TabSelection.creator(creator.id))
								.focused($focusedItem, equals: TabSelection.creator(creator.id))
								.onChange(of: focusedItem, debounceTime: .seconds(0.5), perform: { focusedItem in
									if focusedItem == .creator(creator.id) {
										proxy.scrollTo(focusedItem)
									}
								})
								.onChange(of: focusedItem, perform: { focusedItem in
									
								})
						}
					}
					.padding(30)
				}
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
			}
			.padding(30)
		}
		.background(Color(red: 49.0/256.0, green: 63.0/256.0, blue: 85.0/256.0))
		.defaultFocus($focusedItem, tabSelection, priority: .userInitiated)
		.defaultFocus($focusedItem, tabSelection, priority: .automatic)
	}
	
	func button(for creator: CreatorModelV2) -> some View {
		let showMenu = state == .expanded
		let imageSize: CGFloat = 75 // TODO: change to 50 for channels
		let indent: CGFloat = 0 // TODO: change to 40 for channels, when showing menu
		let isSelected = tabSelection == .creator(creator.id)
		return Button(action: {
			withAnimation {
				tabSelection = .creator(creator.id)
			}
		}, label: {
			HStack(spacing: 0) {
				CachedAsyncImage(url: (creator.icon as ImageModelShared?).bestImage(for: CGSize(width: imageSize, height: imageSize))) { image in
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
//					if item.type == .creator {
//						Image(systemName: "chevron.down")
//					}
				}
			}
			.padding(showMenu || isSelected ? 15 : 0)
			.background(isSelected ? VisualEffectView(effect: UIBlurEffect(style: .light)) : nil)
			.animation(.spring(), value: showMenu)
		})
		.background(.clear)
		.buttonStyle(.card)
	}
}

struct RootTabView2_Previews: PreviewProvider {
	static var previews: some View {
		RootTabView2()
			.environmentObject(MockData.userInfo)
			.environment(\.fpApiService, MockFPAPIService())
	}
}
