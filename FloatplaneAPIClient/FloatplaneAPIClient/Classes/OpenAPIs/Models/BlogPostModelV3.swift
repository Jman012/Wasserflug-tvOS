//
// BlogPostModelV3.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct BlogPostModelV3: Content, Hashable {

    public enum ModelType: String, Content, Hashable, CaseIterable {
        case blogpost = "blogPost"
    }
    public var id: String
    public var guid: String
    public var title: String
    /** Text description of the post. May have HTML paragraph (`<p>`) tags surrounding it, along with other HTML.. */
    public var text: String
    public var type: ModelType
    public var tags: [String]
    public var attachmentOrder: [String]
    public var metadata: PostMetadataModel
    public var releaseDate: Date
    public var likes: Int
    public var dislikes: Int
    public var score: Int
    public var comments: Int
    public var creator: BlogPostModelV3Creator
    public var wasReleasedSilently: Bool
    public var thumbnail: ImageModel?
    /** If false, the post should be marked as locked and not viewable by the user. */
    public var isAccessible: Bool
    public var videoAttachments: [String]?
    public var audioAttachments: [String]?
    public var pictureAttachments: [String]?
    public var galleryAttachments: [String]?

    public init(id: String, guid: String, title: String, text: String, type: ModelType, tags: [String], attachmentOrder: [String], metadata: PostMetadataModel, releaseDate: Date, likes: Int, dislikes: Int, score: Int, comments: Int, creator: BlogPostModelV3Creator, wasReleasedSilently: Bool, thumbnail: ImageModel? = nil, isAccessible: Bool, videoAttachments: [String]? = nil, audioAttachments: [String]? = nil, pictureAttachments: [String]? = nil, galleryAttachments: [String]? = nil) {
        self.id = id
        self.guid = guid
        self.title = title
        self.text = text
        self.type = type
        self.tags = tags
        self.attachmentOrder = attachmentOrder
        self.metadata = metadata
        self.releaseDate = releaseDate
        self.likes = likes
        self.dislikes = dislikes
        self.score = score
        self.comments = comments
        self.creator = creator
        self.wasReleasedSilently = wasReleasedSilently
        self.thumbnail = thumbnail
        self.isAccessible = isAccessible
        self.videoAttachments = videoAttachments
        self.audioAttachments = audioAttachments
        self.pictureAttachments = pictureAttachments
        self.galleryAttachments = galleryAttachments
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case guid
        case title
        case text
        case type
        case tags
        case attachmentOrder
        case metadata
        case releaseDate
        case likes
        case dislikes
        case score
        case comments
        case creator
        case wasReleasedSilently
        case thumbnail
        case isAccessible
        case videoAttachments
        case audioAttachments
        case pictureAttachments
        case galleryAttachments
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(guid, forKey: .guid)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(type, forKey: .type)
        try container.encode(tags, forKey: .tags)
        try container.encode(attachmentOrder, forKey: .attachmentOrder)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(likes, forKey: .likes)
        try container.encode(dislikes, forKey: .dislikes)
        try container.encode(score, forKey: .score)
        try container.encode(comments, forKey: .comments)
        try container.encode(creator, forKey: .creator)
        try container.encode(wasReleasedSilently, forKey: .wasReleasedSilently)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encode(isAccessible, forKey: .isAccessible)
        try container.encodeIfPresent(videoAttachments, forKey: .videoAttachments)
        try container.encodeIfPresent(audioAttachments, forKey: .audioAttachments)
        try container.encodeIfPresent(pictureAttachments, forKey: .pictureAttachments)
        try container.encodeIfPresent(galleryAttachments, forKey: .galleryAttachments)
    }
}

