//
// CdnDeliveryV3ImagePresentationCharacteristics.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct CdnDeliveryV3ImagePresentationCharacteristics: Content, Hashable {

    /** Count of horizontal pixels presented. */
    public var width: Int?
    /** Count of vertical pixels presented. */
    public var height: Int?
    /** Whether or not this data stream carries HDR content. */
    public var isHdr: Bool?

    public init(width: Int? = nil, height: Int? = nil, isHdr: Bool? = nil) {
        self.width = width
        self.height = height
        self.isHdr = isHdr
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case width
        case height
        case isHdr
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(isHdr, forKey: .isHdr)
    }
}

