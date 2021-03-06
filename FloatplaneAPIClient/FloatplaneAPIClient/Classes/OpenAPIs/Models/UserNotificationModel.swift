//
// UserNotificationModel.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct UserNotificationModel: Content, Hashable {

    public var creator: CreatorModelV2
    public var userNotificationSetting: UserNotificationModelUserNotificationSetting

    public init(creator: CreatorModelV2, userNotificationSetting: UserNotificationModelUserNotificationSetting) {
        self.creator = creator
        self.userNotificationSetting = userNotificationSetting
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case creator
        case userNotificationSetting
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creator, forKey: .creator)
        try container.encode(userNotificationSetting, forKey: .userNotificationSetting)
    }
}

