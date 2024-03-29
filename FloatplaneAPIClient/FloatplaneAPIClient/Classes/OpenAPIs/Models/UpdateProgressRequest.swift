//
// UpdateProgressRequest.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

/**  */
public struct UpdateProgressRequest: Content, Hashable {

    public enum ContentType: String, Content, Hashable, CaseIterable {
        case video = "video"
        case audio = "audio"
    }
    static let progressRule = NumericRule<Int>(minimum: 0, exclusiveMinimum: false, maximum: nil, exclusiveMaximum: false, multipleOf: nil)
    /** The video or audio attachment identifier for the piece of media that is being updated. Note: this is *not* the blogPost identifier. */
    public var id: String
    /** Which type of media the corresponding identifier is. */
    public var contentType: ContentType
    /** The progress through the media that has been consumed by the user, in seconds. */
    public var progress: Int

    public init(id: String, contentType: ContentType, progress: Int) {
        self.id = id
        self.contentType = contentType
        self.progress = progress
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case contentType
        case progress
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(progress, forKey: .progress)
    }
}

