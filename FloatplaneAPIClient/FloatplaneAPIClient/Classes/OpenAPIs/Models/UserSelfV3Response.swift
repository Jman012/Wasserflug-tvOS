//
// UserSelfV3Response.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct UserSelfV3Response: Content, Hashable {

    public var id: String
    public var username: String
    public var profileImage: ImageModel
    public var email: String
    public var displayName: String
    public var creators: [AnyCodable]
    public var scheduledDeletionDate: Date?

    public init(id: String, username: String, profileImage: ImageModel, email: String, displayName: String, creators: [AnyCodable], scheduledDeletionDate: Date?) {
        self.id = id
        self.username = username
        self.profileImage = profileImage
        self.email = email
        self.displayName = displayName
        self.creators = creators
        self.scheduledDeletionDate = scheduledDeletionDate
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case username
        case profileImage
        case email
        case displayName
        case creators
        case scheduledDeletionDate
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(profileImage, forKey: .profileImage)
        try container.encode(email, forKey: .email)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(creators, forKey: .creators)
        try container.encode(scheduledDeletionDate, forKey: .scheduledDeletionDate)
    }
}

