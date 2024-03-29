//
// CdnDeliveryV3MetaAudioAllOf.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct CdnDeliveryV3MetaAudioAllOf: Content, Hashable {

    /** Count of channels carried by the audio stream. */
    public var channelCount: Int?
    /** Count of samples recorded per second. */
    public var samplerate: Int?

    public init(channelCount: Int? = nil, samplerate: Int? = nil) {
        self.channelCount = channelCount
        self.samplerate = samplerate
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case channelCount
        case samplerate
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(channelCount, forKey: .channelCount)
        try container.encodeIfPresent(samplerate, forKey: .samplerate)
    }
}

