//
// PaymentInvoiceListV2ResponseInvoicesInner.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif
import Vapor

public struct PaymentInvoiceListV2ResponseInvoicesInner: Content, Hashable {

    public var id: Int
    public var amountDue: Double
    public var amountTax: Double
    public var attemptCount: Int
    public var currency: String
    public var date: Date
    public var dateDue: Date?
    public var periodStart: Date
    public var periodEnd: Date
    public var nextPaymentAttempt: Date?
    public var paid: Bool
    public var forgiven: Bool
    public var refunded: Bool
    /** The subscriptions this invoice is in reference to. */
    public var subscriptions: [PaymentInvoiceListV2ResponseInvoicesInnerSubscriptionsInner]?

    public init(id: Int, amountDue: Double, amountTax: Double, attemptCount: Int, currency: String, date: Date, dateDue: Date?, periodStart: Date, periodEnd: Date, nextPaymentAttempt: Date?, paid: Bool, forgiven: Bool, refunded: Bool, subscriptions: [PaymentInvoiceListV2ResponseInvoicesInnerSubscriptionsInner]?) {
        self.id = id
        self.amountDue = amountDue
        self.amountTax = amountTax
        self.attemptCount = attemptCount
        self.currency = currency
        self.date = date
        self.dateDue = dateDue
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.nextPaymentAttempt = nextPaymentAttempt
        self.paid = paid
        self.forgiven = forgiven
        self.refunded = refunded
        self.subscriptions = subscriptions
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case amountDue
        case amountTax
        case attemptCount
        case currency
        case date
        case dateDue
        case periodStart
        case periodEnd
        case nextPaymentAttempt
        case paid
        case forgiven
        case refunded
        case subscriptions
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amountDue, forKey: .amountDue)
        try container.encode(amountTax, forKey: .amountTax)
        try container.encode(attemptCount, forKey: .attemptCount)
        try container.encode(currency, forKey: .currency)
        try container.encode(date, forKey: .date)
        try container.encode(dateDue, forKey: .dateDue)
        try container.encode(periodStart, forKey: .periodStart)
        try container.encode(periodEnd, forKey: .periodEnd)
        try container.encode(nextPaymentAttempt, forKey: .nextPaymentAttempt)
        try container.encode(paid, forKey: .paid)
        try container.encode(forgiven, forKey: .forgiven)
        try container.encode(refunded, forKey: .refunded)
        try container.encode(subscriptions, forKey: .subscriptions)
    }
}

