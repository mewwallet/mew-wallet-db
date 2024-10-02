//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import mew_wallet_ios_extensions

extension PurchaseProvider {
  public struct Fiat: MDBXBackedObject {
    public enum PaymentMethod: String, Sendable, Hashable, Equatable, Identifiable {
      public var id: String { self.rawValue }
      
      case card                   = "CARD"
      case visa                   = "VISA"
      case mastercard             = "MASTERCARD"
      case amex                   = "AMEX"
      case applePay               = "APPLE_PAY"
      case googlePay              = "GOOGLE_PAY"
      case paypal                 = "PAYPAL"
      case interac                = "INTERAC"
      case sepa                   = "SEPA"
      case pay4fun                = "PAY_4_FUN"
      case pix                    = "PIX"
      case ach                    = "ACH"
      case unknown                = "_UNKNOWN_"
      
      fileprivate var unfolded: [Self] {
        switch self {
        case .card:               return [.visa, .mastercard]
        case .googlePay:          return []
        case .unknown:            return []
        default:                  return [self]
        }
      }
      
      public init?(rawValue: String) {
        switch rawValue {
        case "CARD":              self = .card
        case "VISA":              self = .visa
        case "MASTERCARD":        self = .mastercard
        case "AMEX":              self = .amex
        case "APPLE_PAY":         self = .applePay
        case "GOOGLE_PAY":        self = .googlePay
        case "PAYPAL":            self = .paypal
        case "INTERAC":           self = .interac
        case "SEPA":              self = .sepa
        case "PAY_4_FUN":         self = .pay4fun
        case "PIX":               self = .pix
        case "ACH":               self = .ach
        default:                  self = .unknown
        }
      }
    }

    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _PurchaseProvider._Fiat
  }
}

// MARK: - PurchaseProvider.Fiat + Properties

extension PurchaseProvider.Fiat {

  // MARK: - Properties

  public var currency: FiatCurrency { FiatCurrency(currencyCode: _wrapped.fiatCurrency) }

  public var paymentMethods: [PaymentMethod] { _wrapped.paymentMethods.compactMap({ PaymentMethod(rawValue: $0) }).flatMap(\.unfolded) }

  public var limits: ClosedRange<Decimal> {
    let min = Decimal(round(_wrapped.limits.min * 100)) / 100
    let max = Decimal(round(_wrapped.limits.max * 100)) / 100
    return min...max
  }
}

// MARK: - _PurchaseProvider._Fiat + ProtoWrappedMessage

extension _PurchaseProvider._Fiat: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PurchaseProvider.Fiat {
    return PurchaseProvider.Fiat(self, chain: chain)
  }
}

// MARK: - PurchaseProvider.Fiat + ProtoWrapper

extension PurchaseProvider.Fiat: ProtoWrapper {
  init(_ wrapped: _PurchaseProvider._Fiat, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - PurchaseProvider.Fiat + Convenient

extension Array where Element == PurchaseProvider.Fiat {
  public func first(for currency: FiatCurrency) -> Element? {
    self.first(where: { $0.currency == currency })
  }
}
