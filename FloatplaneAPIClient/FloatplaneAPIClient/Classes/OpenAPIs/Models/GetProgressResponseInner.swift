//
// GetProgressResponseInner.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct GetProgressResponseInner: Content, Hashable {

    public var id: String
    /** Percentage of the blog post's media that has been consumed so far. Ranges from 0 to 100. */
    public var progress: Int

    public init(id: String, progress: Int) {
        self.id = id
        self.progress = progress
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case progress
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(progress, forKey: .progress)
    }
}
