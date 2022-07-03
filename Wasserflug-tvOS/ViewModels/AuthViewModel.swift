import Foundation
import SwiftUI
import FloatplaneAPIClient

class AuthViewModel: BaseViewModel, ObservableObject {
	
	@Published var isLoadingAuthStatus = true
	@Published var isLoggedIn = false
	@Published var userInfo = UserInfo()
	@Published var authenticationCheckError: Error? = nil
	@Published var showAuthenticationErrorAlert = false
	@Published var showNoSubscriptionsAlert = false
	
	@Published var isAttemptingLogin = false
	@Published var showIncorrectLoginAlert = false
	@Published var loginError: Error? = nil
	@Published var needsSecondFactor = false
	@Published var isAttemptingSecondFactor = false
	@Published var showIncorrectSecondFactorAlert = false
	@Published var secondFactorError: Error? = nil
	
	private let fpApiService: FPAPIService
	
	init(fpApiService: FPAPIService) {
		self.fpApiService = fpApiService
	}
	
	func determineAuthenticationStatus() {
		isLoadingAuthStatus = true
		
		logger.info("Determining authentication status. Retrieving the self object and list of subscriptions.")
		
		// Get self and subscriptions
		fpApiService.getUserSelf()
			.and(fpApiService.listUserSubscriptionsV3())
			.whenComplete { result in
				DispatchQueue.main.async {
					switch result {
					case let .success(responses):
						switch responses {
						case let (.http200(value: userSelfResponse, raw: clientResponseSelf), .http200(value: userSubscriptionsResponse, raw: clientResponseSubs)):
							self.logger.debug("User self raw response: \(clientResponseSelf.plaintextDebugContent)")
							self.logger.debug("User subscriptions raw response: \(clientResponseSubs.plaintextDebugContent)")
							self.logger.notice("Recieved successful user self and subscription responses.", metadata: [
								"userId": "\(userSelfResponse.id)",
								"username": "\(userSelfResponse.username)",
								"subIds": "\(userSubscriptionsResponse.map({ $0.creator }))",
							])
							
							guard !userSubscriptionsResponse.isEmpty else {
								self.logger.warning("Login was successful but the user profile did not return any subscriptions. Aborting authentication process and informing user of inability to proceed.")
								self.isLoggedIn = false
								self.isLoadingAuthStatus = false
								self.showNoSubscriptionsAlert = true
								return
							}
							
							self.isLoggedIn = true
							self.userInfo.userSelf = userSelfResponse
							self.userInfo.userSubscriptions = userSubscriptionsResponse
							
							// With the subscriptions, get the creators of the subscriptions.
							// Convert to Set to remove possible duplicates (which is possible).
							let creatorGuids = Set<String>(self.userInfo.userSubscriptions.map({ $0.creator }))
							self.logger.info("Loading creator(s) information from subscriptions", metadata: [
								"creatorGuids": "\(creatorGuids)",
							])
							self.fpApiService.getInfo(creatorGUID: Array<String>(creatorGuids))
								.whenComplete { result in
									DispatchQueue.main.async {
										switch result {
										case let .success(response):
											switch response {
											case let .http200(value: response, raw: clientResponseCreators):
												self.logger.debug("Creator(s) information raw content: \(clientResponseCreators.plaintextDebugContent)")
												self.logger.notice("Retrieved \(response.count) creator(s) information.")
												self.userInfo.creators = Dictionary(uniqueKeysWithValues: response.map({ ($0.id, $0) }))
												
												// With the creators, get the creator owners
												let ownerIds = response.map({ $0.owner })
												self.logger.info("Loading creator owner(s) information.", metadata: [
													"ownerIds": "\(ownerIds)",
												])
												self.fpApiService.getUsers(ids: ownerIds)
													.whenComplete { result in
														DispatchQueue.main.async {
															self.isLoadingAuthStatus = false
															switch result {
															case let .success(response):
																switch response {
																case let .http200(value: response, raw: clientResponseCreatorOwners):
																	self.logger.debug("Creator owner(s) raw response: \(clientResponseCreatorOwners.plaintextDebugContent)")
																	self.logger.notice("Retrieved creator owner(s) information", metadata: [
																		"names": "\(response.users.map({ $0.user.username }))",
																	])
																	self.userInfo.creatorOwners = Dictionary(uniqueKeysWithValues: response.users.map({ ($0.user.id, $0.user) }))
																case let .http0(value: errorModel, raw: clientResponse),
																	let .http400(value: errorModel, raw: clientResponse),
																	let .http401(value: errorModel, raw: clientResponse),
																	let .http403(value: errorModel, raw: clientResponse),
																	let .http404(value: errorModel, raw: clientResponse):
																	self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading creator owner(s). Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
																	self.isLoggedIn = false
																	self.isLoadingAuthStatus = false
																	self.authenticationCheckError = errorModel
																	self.showAuthenticationErrorAlert = true
																}
															case let .failure(error):
																self.logger.error("Encountered an unexpected error while loading creator owner(s). Reporting the error to the user. Error: \(String(reflecting: error))")
																self.isLoggedIn = false
																self.isLoadingAuthStatus = false
																self.authenticationCheckError = error
																self.showAuthenticationErrorAlert = true
															}
														}
													}
											case let .http0(value: errorModel, raw: clientResponse),
												let .http400(value: errorModel, raw: clientResponse),
												let .http401(value: errorModel, raw: clientResponse),
												let .http403(value: errorModel, raw: clientResponse),
												let .http404(value: errorModel, raw: clientResponse):
												self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while loading creator(s). Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
												self.isLoggedIn = false
												self.isLoadingAuthStatus = false
												self.authenticationCheckError = errorModel
												self.showAuthenticationErrorAlert = true
											}
										case let .failure(error):
											self.logger.error("Encountered an unexpected error while loading creator(s). Reporting the error to the user. Error: \(String(reflecting: error))")
											self.isLoggedIn = false
											self.isLoadingAuthStatus = false
											self.authenticationCheckError = error
											self.showAuthenticationErrorAlert = true
										}
									}
								}
						default:
							self.logger.notice("Received invalid responses for user self and user subscriptions. Assuming user is not logged in. Showing login screen to user.")
							self.logger.debug("User self response: \(responses.0)")
							self.logger.debug("User subscriptions response: \(responses.1)")
							self.isLoggedIn = false
							self.isLoadingAuthStatus = false
						}
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while loading user self and subscriptions. Reporting the error to the user. Showing login screen. Error: \(String(reflecting: error))")
						self.isLoggedIn = false
						self.isLoadingAuthStatus = false
						self.authenticationCheckError = error
						self.showAuthenticationErrorAlert = true
					}
				}
			}
	}
	
	func attemptLogin(username: String, password: String, isLoggedIn: @escaping () -> Void) {
		isAttemptingLogin = true
		
		logger.info("Attempting login action.", metadata: [
			"username": "\(username)",
		])
		
		fpApiService.login(username: username, password: password, captchaToken: nil)
			.whenComplete { result in
				DispatchQueue.main.async {
					self.isAttemptingLogin = false
					
					switch result {
					case let .success(response):
						switch response {
						case let .http200(value: response, raw: clientResponse):
							self.logger.debug("Successful login raw response: \(clientResponse.plaintextDebugContent)")
							// Set global cookie
							FloatplaneAPIClientAPI.storeAuthentifcationCookies(from: clientResponse)
							
							if response.needs2FA {
								self.logger.notice("Successfully logged in as user '\(username)'. Requires second factor to continue authentication process.")
								self.needsSecondFactor = true
							} else {
								self.logger.notice("Successfully logged in as user '\(username)'. No second factor required.", metadata: [
									"id": "\(response.user?.id ?? "<no user object found>")",
									"username": "\(response.user?.username ?? "<no user object found>")",
								])
								isLoggedIn()
							}
						case let .http401(value: response, raw: clientResponse):
							self.logger.debug("Unsuccessfull login raw response: \(clientResponse.plaintextDebugContent)")
							self.logger.notice("Login attempt failed, received unauthorized response. ErrorModel: \(String(describing: response))")
							self.showIncorrectLoginAlert = true
						case let .http0(value: errorModel, raw: clientResponse),
							let .http400(value: errorModel, raw: clientResponse),
							let .http403(value: errorModel, raw: clientResponse),
							let .http404(value: errorModel, raw: clientResponse):
							self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while attempting login. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
							self.showIncorrectLoginAlert = true
							self.loginError = errorModel
						}
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while attempting login. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.showIncorrectLoginAlert = true
						self.loginError = error
					}
				}
			}
	}
	
	func attemptSecondFactor(secondFactorCode: String, isLoggedIn: @escaping () -> Void) {
		isAttemptingSecondFactor = true
		logger.info("Attempting 2fa action for login process.")
		
		fpApiService.secondFactor(token: secondFactorCode)
			.whenComplete { result in
				DispatchQueue.main.async {
					self.isAttemptingSecondFactor = false
					
					switch result {
					case let .success(response):
						switch response {
						case let .http200(value: response, raw: clientResponse):
							self.logger.debug("Successful 2fa raw response: \(clientResponse.plaintextDebugContent)")
							self.logger.notice("Successfully resolved second factor in login process.", metadata: [
								"id": "\(response.user?.id ?? "<no user object found>")",
								"username": "\(response.user?.username ?? "<no user object found>")",
							])
							// Set global cookie
							FloatplaneAPIClientAPI.storeAuthentifcationCookies(from: clientResponse)
							
							isLoggedIn()
						case let .http401(value: response, raw: clientResponse):
							self.logger.debug("Unsuccessfull 2fa raw response: \(clientResponse.plaintextDebugContent)")
							self.logger.notice("2fa attempt failed, received unauthorized response. ErrorModel: \(String(describing: response))")
							self.showIncorrectSecondFactorAlert = true
						case let .http0(value: errorModel, raw: clientResponse),
							let .http400(value: errorModel, raw: clientResponse),
							let .http403(value: errorModel, raw: clientResponse),
							let .http404(value: errorModel, raw: clientResponse):
							self.logger.warning("Received an unexpected HTTP status (\(clientResponse.status.code)) while attempting 2fa. Reporting the error to the user. Error Model: \(String(reflecting: errorModel)).")
							self.showIncorrectSecondFactorAlert = true
							self.secondFactorError = errorModel
						}
					case let .failure(error):
						self.logger.error("Encountered an unexpected error while attempting 2fa. Reporting the error to the user. Error: \(String(reflecting: error))")
						self.showIncorrectSecondFactorAlert = true
						self.secondFactorError = error
					}
				}
			}
	}
}

class UserInfo: ObservableObject {
	@Published var userSelf: UserSelfV3Response?
	@Published var userSubscriptions: [UserSubscriptionModel] = []
	@Published var creators: [String: CreatorModelV2] = [:]
	@Published var creatorOwners: [String: UserModel] = [:] {
		didSet {
			setCreatorsInOrder()
		}
	}
	@Published var creatorsInOrder: [(CreatorModelV2, UserModel)] = []
	
	private func setCreatorsInOrder() {
		for sub in userSubscriptions {
			if !creatorsInOrder.contains(where: { $0.0.id == sub.creator }) {
				if let creator = creators[sub.creator], let creatorOwner = creatorOwners[creator.owner] {
					creatorsInOrder.append((creator, creatorOwner))
				}
			}
		}
	}
}
