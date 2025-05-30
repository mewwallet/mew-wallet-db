//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/21/25.
//

import Foundation
import SwiftProtobuf
 
public struct BalancesV3Wrapper: MDBXWrapperObject, Sendable {
  var _chain: MDBXChain
  var _wrapped: _BalancesV3Wrapper
  public weak var database: (any WalletDB)?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _BalancesV3Wrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _BalancesV3Wrapper(jsonUTF8Data: jsonData, options: options)
  }
  
  public var address: Address {
    return Address(self._wrapped.address)
  }
}

// MARK: - BalancesV3Wrapper + Properties

extension BalancesV3Wrapper {
  
  // MARK: - Properties
  
  public var metas: [TokenMeta] {
    return self._wrapped.balances.map { balance in
      return TokenMeta(
        chain: self._chain,
        contractAddress: Address(balance.contractAddress),
        name: balance.name,
        symbol: balance.symbol,
        decimals: balance.decimals,
        icon: balance.icon,
        price: balance.hasPrice ? balance.price : nil,
        sparkline: balance.sparkline,
        database: database
      )
    }
  }
  
  public var tokens: [Token] {
    return self._wrapped.balances.map { balance in
      return Token(
        chain: self._chain,
        address: self.address,
        contractAddress: Address(balance.contractAddress),
        rawAmount: balance.amount,
        lockedAmount: balance.lockedAmount,
        database: database
      )
    }
  }
}

// MARK: - BalancesV3Wrapper + ProtoWrappedMessage

extension _BalancesV3Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> BalancesV3Wrapper {
    return BalancesV3Wrapper(self, chain: chain)
  }
}

// MARK: - BalancesV3Wrapper + ProtoWrapper

extension BalancesV3Wrapper: ProtoWrapper {
  init(_ wrapped: _BalancesV3Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

extension BalancesV3Wrapper {
  public static func array(fromJSONString: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    return try _BalancesV3Wrapper.array(fromJSONString: fromJSONString, options: options).map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONUTF8Data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    return try _BalancesV3Wrapper.array(fromJSONUTF8Data: fromJSONUTF8Data, options: options).map({ $0.wrapped(chain) })
  }
}

// MARK: Array<BalancesV3Wrapper> + Properties

extension Array where Element == BalancesV3Wrapper {
  public var metas: [TokenMeta] {
    return self.flatMap(\.metas)
  }
  
  public var tokens: [Token] {
    return self.flatMap(\.tokens)
  }
}
