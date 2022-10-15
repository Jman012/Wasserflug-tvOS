//
// CdnDeliveryV3MetaVideo.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct CdnDeliveryV3MetaVideo: Content, Hashable {

    /** RFC 6381 codec string indicating stream data chunk format. */
    public var codec: String?
    /** RFC 6381 codec string indicating stream format on the most basic level, without the addition of profile/level/etc. information. */
    public var codecSimple: String?
    /** MIME-type for individual stream data chunks (as opposed to a containing playlist). */
    public var mimeType: String?
    /** Count of horizontal pixels presented. */
    public var width: Int?
    /** Count of vertical pixels presented. */
    public var height: Int?
    /** Whether or not this data stream carries HDR content. */
    public var isHdr: Bool?
    /** Maximum count of frames presented per second for the video. */
    public var fps: Double?
    public var bitrate: CdnDeliveryV3MediaBitrateInfoBitrate?

    public init(codec: String? = nil, codecSimple: String? = nil, mimeType: String? = nil, width: Int? = nil, height: Int? = nil, isHdr: Bool? = nil, fps: Double? = nil, bitrate: CdnDeliveryV3MediaBitrateInfoBitrate? = nil) {
        self.codec = codec
        self.codecSimple = codecSimple
        self.mimeType = mimeType
        self.width = width
        self.height = height
        self.isHdr = isHdr
        self.fps = fps
        self.bitrate = bitrate
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case codec
        case codecSimple
        case mimeType
        case width
        case height
        case isHdr
        case fps
        case bitrate
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(codec, forKey: .codec)
        try container.encodeIfPresent(codecSimple, forKey: .codecSimple)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(isHdr, forKey: .isHdr)
        try container.encodeIfPresent(fps, forKey: .fps)
        try container.encodeIfPresent(bitrate, forKey: .bitrate)
    }
}
