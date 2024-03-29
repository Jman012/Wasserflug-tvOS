//
// ContentPictureV3Response.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct ContentPictureV3Response: Content, Hashable {

    public enum UserInteraction: String, Content, Hashable, CaseIterable {
        case like = "like"
        case dislike = "dislike"
    }
    public var id: String
    public var guid: String
    public var title: String
    public var type: String
    public var description: String
    public var likes: Int
    public var dislikes: Int
    public var score: Int
    public var isProcessing: Bool
    public var creator: String
    public var primaryBlogPost: String
    public var userInteraction: [UserInteraction]?
    public var thumbnail: ImageModel
    /** If false, the post should be marked as locked and not viewable by the user. */
    public var isAccessible: Bool
    public var imageFiles: [ImageFileModel]

    public init(id: String, guid: String, title: String, type: String, description: String, likes: Int, dislikes: Int, score: Int, isProcessing: Bool, creator: String, primaryBlogPost: String, userInteraction: [UserInteraction]?, thumbnail: ImageModel, isAccessible: Bool, imageFiles: [ImageFileModel]) {
        self.id = id
        self.guid = guid
        self.title = title
        self.type = type
        self.description = description
        self.likes = likes
        self.dislikes = dislikes
        self.score = score
        self.isProcessing = isProcessing
        self.creator = creator
        self.primaryBlogPost = primaryBlogPost
        self.userInteraction = userInteraction
        self.thumbnail = thumbnail
        self.isAccessible = isAccessible
        self.imageFiles = imageFiles
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case guid
        case title
        case type
        case description
        case likes
        case dislikes
        case score
        case isProcessing
        case creator
        case primaryBlogPost
        case userInteraction
        case thumbnail
        case isAccessible
        case imageFiles
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(guid, forKey: .guid)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(likes, forKey: .likes)
        try container.encode(dislikes, forKey: .dislikes)
        try container.encode(score, forKey: .score)
        try container.encode(isProcessing, forKey: .isProcessing)
        try container.encode(creator, forKey: .creator)
        try container.encode(primaryBlogPost, forKey: .primaryBlogPost)
        try container.encode(userInteraction, forKey: .userInteraction)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(isAccessible, forKey: .isAccessible)
        try container.encode(imageFiles, forKey: .imageFiles)
    }
}

