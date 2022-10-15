//
// CdnDeliveryV2DownloadResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct CdnDeliveryV2DownloadResponse: Content, Hashable {

    public enum Strategy: String, Content, Hashable, CaseIterable {
        case cdn = "cdn"
        case client = "client"
    }
    public var edges: [EdgeModel]
    public var client: [String: AnyCodable]
    /** Which download/streaming strategy to use. If `cdn`, then a `cdn` property will be included with the response. Otherwise, if set to `client`, then a `client` property will be included with the response. The cdn or client property should be combined with the `resource` property to perform the download/stream. */
    public var strategy: Strategy
    public var resource: CdnDeliveryV2ResourceModel

    public init(edges: [EdgeModel], client: [String: AnyCodable], strategy: Strategy, resource: CdnDeliveryV2ResourceModel) {
        self.edges = edges
        self.client = client
        self.strategy = strategy
        self.resource = resource
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case edges
        case client
        case strategy
        case resource
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(edges, forKey: .edges)
        try container.encode(client, forKey: .client)
        try container.encode(strategy, forKey: .strategy)
        try container.encode(resource, forKey: .resource)
    }
}
