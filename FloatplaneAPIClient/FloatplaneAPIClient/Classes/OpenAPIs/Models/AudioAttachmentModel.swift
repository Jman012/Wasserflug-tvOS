//
// AudioAttachmentModel.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct AudioAttachmentModel: Content, Hashable {

    public var id: String
    public var guid: String
    public var title: String
    public var type: String
    public var description: String
    public var duration: Int
    public var waveform: AudioAttachmentModelWaveform
    public var creator: String
    public var likes: Int
    public var dislikes: Int
    public var score: Int
    public var isProcessing: Bool
    public var primaryBlogPost: String
    /** If false, the post should be marked as locked and not viewable by the user. */
    public var isAccessible: Bool

    public init(id: String, guid: String, title: String, type: String, description: String, duration: Int, waveform: AudioAttachmentModelWaveform, creator: String, likes: Int, dislikes: Int, score: Int, isProcessing: Bool, primaryBlogPost: String, isAccessible: Bool) {
        self.id = id
        self.guid = guid
        self.title = title
        self.type = type
        self.description = description
        self.duration = duration
        self.waveform = waveform
        self.creator = creator
        self.likes = likes
        self.dislikes = dislikes
        self.score = score
        self.isProcessing = isProcessing
        self.primaryBlogPost = primaryBlogPost
        self.isAccessible = isAccessible
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case guid
        case title
        case type
        case description
        case duration
        case waveform
        case creator
        case likes
        case dislikes
        case score
        case isProcessing
        case primaryBlogPost
        case isAccessible
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(guid, forKey: .guid)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(duration, forKey: .duration)
        try container.encode(waveform, forKey: .waveform)
        try container.encode(creator, forKey: .creator)
        try container.encode(likes, forKey: .likes)
        try container.encode(dislikes, forKey: .dislikes)
        try container.encode(score, forKey: .score)
        try container.encode(isProcessing, forKey: .isProcessing)
        try container.encode(primaryBlogPost, forKey: .primaryBlogPost)
        try container.encode(isAccessible, forKey: .isAccessible)
    }
}

