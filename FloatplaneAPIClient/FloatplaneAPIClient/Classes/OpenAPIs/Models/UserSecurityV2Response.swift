//
// UserSecurityV2Response.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct UserSecurityV2Response: Content, Hashable {

    public var twofactorEnabled: Bool
    public var twofactorBackupCodeEnabled: Bool

    public init(twofactorEnabled: Bool, twofactorBackupCodeEnabled: Bool) {
        self.twofactorEnabled = twofactorEnabled
        self.twofactorBackupCodeEnabled = twofactorBackupCodeEnabled
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case twofactorEnabled
        case twofactorBackupCodeEnabled
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(twofactorEnabled, forKey: .twofactorEnabled)
        try container.encode(twofactorBackupCodeEnabled, forKey: .twofactorBackupCodeEnabled)
    }
}

