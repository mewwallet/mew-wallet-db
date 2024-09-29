//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import SwiftProtobuf

public struct PurchaseToken: Equatable {
  public var database: (any WalletDB)? {
    get { MEWwalletDBImpl.shared }
    set {}
  }
  var _wrapped: _PurchaseToken = .with({ _ in })
  var _chain: MDBXChain = .universal
  public var order: UInt16? = nil

  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _providers: MDBXRelationship<PurchaseProvider.Key, PurchaseProvider> = .init(.purchaseProviders)

  // MARK: - Lifecycle

  public init() {
  }
}

// MARK: - PurchaseToken + Properties

extension PurchaseToken {
  // MARK: - Relations

  public var meta: TokenMeta {
    get throws {
      let key = TokenMetaKey(chain: _chain, contractAddress: self.contract_address)
      return try _meta.getData(key: key, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }

  public var providers: [PurchaseProvider] {
    get throws {
      let range = PurchaseProvider.Key.range(chain: self._chain)
      let ids = self.providersIDs
      guard !ids.isEmpty else { return [] }
      return try _providers.getRelationship(range, policy: .cacheOrLoad, order: .asc, chain: _chain, database: self.database)
        .filter({ ids.contains($0.id) })
    }
  }

  public var providersIDs: [PurchaseProvider.ID] {
    self._wrapped.providers.compactMap({
      guard let name = PurchaseProvider.Name(rawValue: $0) else { return nil }
      return PurchaseProvider.ID(chain: self._chain, name: name)
    })
  }

  // MARK: - Properties

  public var symbol: String { self._wrapped.symbol }
  public var name: String { self._wrapped.name }
  public var contract_address: Address { Address(rawValue: self._wrapped.contractAddress) }
}

// MARK: - PurchaseToken + MDBXObject

extension PurchaseToken: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    return PurchaseToken.Key(chain: _chain, order: self.order ?? 0, contractAddress: self.contract_address)
  }

  public var alternateKey: (any MDBXKey)? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _PurchaseToken(serializedBytes: data)
    commonInit(chain: chain, key: key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PurchaseToken(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: chain, key: key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PurchaseToken(jsonString: jsonString, options: options)
    commonInit(chain: chain, key: key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _PurchaseToken.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _PurchaseToken.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! PurchaseToken

    self._wrapped.symbol = other._wrapped.symbol
    self._wrapped.name = other._wrapped.name
    self._wrapped.contractAddress = other._wrapped.contractAddress
  }
}

// MARK: - _PurchaseToken + ProtoWrappedMessage

extension _PurchaseToken: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PurchaseToken {
    var provider = PurchaseToken(self, chain: chain)
    provider.commonInit(chain: chain, key: nil)
    return provider
  }
}

// MARK: - PurchaseToken + Equitable

extension PurchaseToken {
  public static func == (lhs: PurchaseToken, rhs: PurchaseToken) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - PurchaseToken + ProtoWrapper

extension PurchaseToken: ProtoWrapper {
  init(_ wrapped: _PurchaseToken, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - PurchaseToken + Identifiable

extension PurchaseToken: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._chain.hexString + self.contract_address.rawValue }
}

// MARK: - PurchaseToken + Sendable

extension PurchaseToken: Sendable {}

// MARK: - PurchaseToken + CommonInit

extension PurchaseToken {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    // Wrappers
  }
}
