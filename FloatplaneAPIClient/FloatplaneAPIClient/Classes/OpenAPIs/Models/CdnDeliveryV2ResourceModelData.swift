//
// CdnDeliveryV2ResourceModelData.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct CdnDeliveryV2ResourceModelData: Content, Hashable {

    public var qualityLevels: [CdnDeliveryV2QualityLevelModel]?
    /** For each `qualityLevel` above, there will be an entry in this map where the property name matches the `qulityLevel[].name` containing a token to apply to the URL. */
    public var qualityLevelParams: [String: AnyCodable]?

    public init(qualityLevels: [CdnDeliveryV2QualityLevelModel]? = nil, qualityLevelParams: [String: AnyCodable]? = nil) {
        self.qualityLevels = qualityLevels
        self.qualityLevelParams = qualityLevelParams
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case qualityLevels
        case qualityLevelParams
    }

    public var additionalProperties: [String: AnyCodable] = [:]

    public subscript(key: String) -> AnyCodable? {
        get {
            if let value = additionalProperties[key] {
                return value
            }
            return nil
        }

        set {
            additionalProperties[key] = newValue
        }
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(qualityLevels, forKey: .qualityLevels)
        try container.encodeIfPresent(qualityLevelParams, forKey: .qualityLevelParams)
        var additionalPropertiesContainer = encoder.container(keyedBy: String.self)
        try additionalPropertiesContainer.encodeMap(additionalProperties)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        qualityLevels = try container.decodeIfPresent([CdnDeliveryV2QualityLevelModel].self, forKey: .qualityLevels)
        qualityLevelParams = try container.decodeIfPresent([String: AnyCodable].self, forKey: .qualityLevelParams)
        var nonAdditionalPropertyKeys = Set<String>()
        nonAdditionalPropertyKeys.insert("qualityLevels")
        nonAdditionalPropertyKeys.insert("qualityLevelParams")
        let additionalPropertiesContainer = try decoder.container(keyedBy: String.self)
        additionalProperties = try additionalPropertiesContainer.decodeMap(AnyCodable.self, excludedKeys: nonAdditionalPropertyKeys)
    }
}

