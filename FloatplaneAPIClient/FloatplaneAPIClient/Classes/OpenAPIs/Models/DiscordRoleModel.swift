//
// DiscordRoleModel.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct DiscordRoleModel: Content, Hashable {

    public var server: String
    public var roleName: String

    public init(server: String, roleName: String) {
        self.server = server
        self.roleName = roleName
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case server
        case roleName
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(server, forKey: .server)
        try container.encode(roleName, forKey: .roleName)
    }
}

