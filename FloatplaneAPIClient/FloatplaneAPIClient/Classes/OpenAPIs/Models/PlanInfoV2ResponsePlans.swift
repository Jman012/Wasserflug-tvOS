//
// PlanInfoV2ResponsePlans.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct PlanInfoV2ResponsePlans: Content, Hashable {

    /** The available roles for the associated Discord servers that are available with this plan. */
    public var discordRoles: [DiscordRoleModel]
    public var createdAt: Date
    public var updatedAt: Date
    public var id: String
    public var title: String
    public var enabled: Bool
    public var featured: Bool
    public var description: String
    public var price: String
    public var priceYearly: String?
    public var paymentID: Int
    public var currency: String
    public var trialPeriod: Double
    public var allowGrandfatheredAccess: Bool?
    public var logo: String
    public var creator: String
    public var discordServers: [DiscordServerModel]
    public var userIsSubscribed: Bool
    public var userIsGrandfathered: Bool
    public var enabledGlobal: Bool
    public var interval: String

    public init(discordRoles: [DiscordRoleModel], createdAt: Date, updatedAt: Date, id: String, title: String, enabled: Bool, featured: Bool, description: String, price: String, priceYearly: String? = nil, paymentID: Int, currency: String, trialPeriod: Double, allowGrandfatheredAccess: Bool? = nil, logo: String, creator: String, discordServers: [DiscordServerModel], userIsSubscribed: Bool, userIsGrandfathered: Bool, enabledGlobal: Bool, interval: String) {
        self.discordRoles = discordRoles
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.title = title
        self.enabled = enabled
        self.featured = featured
        self.description = description
        self.price = price
        self.priceYearly = priceYearly
        self.paymentID = paymentID
        self.currency = currency
        self.trialPeriod = trialPeriod
        self.allowGrandfatheredAccess = allowGrandfatheredAccess
        self.logo = logo
        self.creator = creator
        self.discordServers = discordServers
        self.userIsSubscribed = userIsSubscribed
        self.userIsGrandfathered = userIsGrandfathered
        self.enabledGlobal = enabledGlobal
        self.interval = interval
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case discordRoles
        case createdAt
        case updatedAt
        case id
        case title
        case enabled
        case featured
        case description
        case price
        case priceYearly
        case paymentID
        case currency
        case trialPeriod
        case allowGrandfatheredAccess
        case logo
        case creator
        case discordServers
        case userIsSubscribed
        case userIsGrandfathered
        case enabledGlobal
        case interval
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(discordRoles, forKey: .discordRoles)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(featured, forKey: .featured)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(priceYearly, forKey: .priceYearly)
        try container.encode(paymentID, forKey: .paymentID)
        try container.encode(currency, forKey: .currency)
        try container.encode(trialPeriod, forKey: .trialPeriod)
        try container.encodeIfPresent(allowGrandfatheredAccess, forKey: .allowGrandfatheredAccess)
        try container.encode(logo, forKey: .logo)
        try container.encode(creator, forKey: .creator)
        try container.encode(discordServers, forKey: .discordServers)
        try container.encode(userIsSubscribed, forKey: .userIsSubscribed)
        try container.encode(userIsGrandfathered, forKey: .userIsGrandfathered)
        try container.encode(enabledGlobal, forKey: .enabledGlobal)
        try container.encode(interval, forKey: .interval)
    }
}

