//
// UserModel.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

/** Represents some basic information of a user (id, username, and profile image). */
public struct UserModel: Content, Hashable {

    public var id: String
    public var username: String
    public var profileImage: ImageModel

    public init(id: String, username: String, profileImage: ImageModel) {
        self.id = id
        self.username = username
        self.profileImage = profileImage
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case username
        case profileImage
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(profileImage, forKey: .profileImage)
    }
}

