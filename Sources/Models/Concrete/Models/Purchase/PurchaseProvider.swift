//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import SwiftProtobuf
import mew_wallet_ios_extensions

public struct PurchaseProvider {
  public enum Name: String, Sendable, Hashable, Equatable, Identifiable {
    public var id: String { self.rawValue }
    
    case simplex    = "SIMPLEX"
    case moonpay    = "MOONPAY"
    case coinbase   = "COINBASE"
    case topper     = "TOPPER"
    case unknown    = "UNKNOWN"
    
    public init?(rawValue: String) {
      switch rawValue {
      case "SIMPLEX":   self = .simplex
      case "MOONPAY":   self = .moonpay
      case "COINBASE":  self = .coinbase
      case "TOPPER":    self = .topper
      default:          self = .unknown
      }
    }
  }

  public var database: (any WalletDB)? {
    get { MEWwalletDBImpl.shared }
    set {}
  }
  var _wrapped: _PurchaseProvider = .with({ _ in })
  var _chain: MDBXChain = .evm
  public var order: UInt16? = nil
  @SubProperty<[_PurchaseProvider._Fiat], [PurchaseProvider.Fiat]> var _fiats: [_PurchaseProvider._Fiat]?
  @SubProperty<_PurchaseProvider._ISO, PurchaseProvider.ISO> var _iso: _PurchaseProvider._ISO?

  public init() {
  }
}

// MARK: - PurchaseProvider + Properties

extension PurchaseProvider {
  // MARK: - Properties

  public var name: PurchaseProvider.Name { PurchaseProvider.Name(rawValue: self._wrapped.provider) ?? .unknown }

  public var fiats: [PurchaseProvider.Fiat] {
    guard !_wrapped.fiats.isEmpty else { return [] }
    return self.$_fiats ?? []
  }
  
  public var currencies: [FiatCurrency] {
    self.fiats.map(\.currency)
  }

  public var buy: Bool { self.$_iso?.buy ?? false }

  public var sell: Bool { self.$_iso?.sell ?? false }
}

// MARK: - PurchaseProvider + MDBXObject

extension PurchaseProvider: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    return PurchaseProvider.Key(chain: _chain, order: self.order ?? 0, name: _wrapped.provider)
  }

  public var alternateKey: (any MDBXKey)? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _PurchaseProvider(serializedBytes: data)
    commonInit(chain: chain, key: key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PurchaseProvider(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: chain, key: key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PurchaseProvider(jsonString: jsonString, options: options)
    commonInit(chain: chain, key: key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _PurchaseProvider.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _PurchaseProvider.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! PurchaseProvider

    self._wrapped.provider = other._wrapped.provider
    self._wrapped.isos = other._wrapped.isos
    self._wrapped.fiats = other._wrapped.fiats
  }
}

// MARK: - _PurchaseProvider + ProtoWrappedMessage

extension _PurchaseProvider: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PurchaseProvider {
    var provider = PurchaseProvider(self, chain: chain)
    provider.commonInit(chain: chain, key: nil)
    return provider
  }
}

// MARK: - PurchaseProvider + Equatable

extension PurchaseProvider: Equatable {
  public static func == (lhs: PurchaseProvider, rhs: PurchaseProvider) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - PurchaseProvider + ProtoWrapper

extension PurchaseProvider: ProtoWrapper {
  init(_ wrapped: _PurchaseProvider, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - PurchaseProvider + Identifiable

extension PurchaseProvider: Identifiable {
  public struct ProviderID: Sendable, Hashable {
    let chain: MDBXChain
    let name: PurchaseProvider.Name
  }
  /// The stable identity of the entity associated with this instance.
  public var id: ProviderID { ProviderID(chain: self._chain, name: self.name) }
}

// MARK: - PurchaseProvider + CommonInit

extension PurchaseProvider {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    // Wrappers
    __fiats.chain = chain
    __fiats.refreshProjected(wrapped: _wrapped.fiats)

    __iso.chain = chain
    __iso.refreshProjected(wrapped: _wrapped.isos.first)
  }
}

// MARK: - PurchaseProvider + Convenient

extension Array where Element == PurchaseProvider {
  public func filter(for currency: FiatCurrency, with amount: Decimal) -> [Element] {
    filter {
      guard $0.name != .unknown else { return false }
      guard let fiat = $0.fiats.first(where: { $0.currency == currency }) else { return false }
      return fiat.limits.contains(amount)
    }
  }
  
  public func limit(for currency: FiatCurrency) -> ClosedRange<Decimal> {
    let providersFiats = self.flatMap(\.fiats).filter({ $0.currency == currency })
    let min = providersFiats.min(by: { $0.limits.lowerBound < $1.limits.lowerBound })?.limits.lowerBound ?? .zero
    let max = providersFiats.max(by: { $0.limits.upperBound < $1.limits.upperBound })?.limits.upperBound ?? .zero
    return min...max
  }
  
  public var currencies: [FiatCurrency] {
    return [FiatCurrency](
      Set(self.flatMap { $0.currencies })
    ).sorted(by: <)
  }
  
  public func payment_methods(for currency: FiatCurrency) -> [PurchaseProvider.Fiat.PaymentMethod] {
    let providersFiats = self.flatMap(\.fiats).filter({ $0.currency == currency })
    let paymentMethods = Set(providersFiats.flatMap(\.paymentMethods))
    return paymentMethods.sorted(by: <)
  }
}
