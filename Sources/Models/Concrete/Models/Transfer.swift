//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/23/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Transfer: Equatable {
  public enum Direction: UInt8 {
    case `self`
    case outgoing
    case incoming
  }
  public enum Status: String {
    case pending = "PENDING"
    case success = "SUCCESS"
    case failed  = "FAIL"
    case dropped = "DROPPED"
  }
  
  public weak var database: WalletDB?
  var _wrapped: _Transfer
  var _chain: MDBXChain
  public var order: UInt16?
  
  // MARK: - Private Properties
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _primaryMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _from: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _to: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _owner: MDBXPointer<AccountKey, Account> = .init(.account)
  @SubProperty<_NFTTransfer, NFTTransfer> var _nftTransfer: _NFTTransfer?
  
//  private let _dexItem: MDBXPointer<DexItemKey, DexItem> = .init(.dex)
  
  // MARK: - LifeCycle
   
  public init(chain: MDBXChain,
              address: Address,
              hash: String,
              contractAddress: Address,
              from: Address,
              to: Address,
              blockNumber: UInt64,
              nonce: UInt64,
              delta: Decimal,
              timestamp: Date,
              status: Status,
              nft: NFTTransfer?,
              local: Bool,
              database: WalletDB? = nil) {

    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      
      $0.address = address.rawValue
      $0.from = from.rawValue
      $0.to = to.rawValue
      
      $0.hash = hash
      $0.contractAddress = address.rawValue
      $0.blockNumber = blockNumber
      $0.nonce = nonce
      $0.delta = delta.hexString
      $0.timestamp = .init(date: timestamp)
      $0.status = status.rawValue
      $0.local = local
      if let nft = nft {
        $0.nft = nft._wrapped
      }
    }
    self._chain = chain
  }
}

// MARK: - Transfer + Properties

extension Transfer {
  // MARK: - Relations
//
//  public var dexItem: DexItem {
//    get throws {
//      let key = DexItemKey(chain: _chain, contractAddress: self.contract_address)
//      return try _dexItem.getData(key: key, policy: .cacheOrLoad, database: self.database)
//    }
//  }
  
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.contractAddress)
      return try _meta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  public var primary: TokenMeta {
    get throws {
      return try _primaryMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: .primary), policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  public var from: Account {
    get throws {
      let address = Address(rawValue: _wrapped.from)
      return try _from.getData(key: AccountKey(address: address), policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }
  
  public var to: Account {
    get throws {
      let address = Address(rawValue: _wrapped.to)
      return try _to.getData(key: AccountKey(address: address), policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }
  
  public var owner: Account {
    get throws {
      let address = Address(rawValue: _wrapped.address)
      return try _owner.getData(key: AccountKey(address: address), policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var hash: String { _wrapped.hash }
  public var address: Address { Address(rawValue: self._wrapped.address) }
  public var fromAddress: Address { Address(rawValue: self._wrapped.from) }
  public var toAddress: Address { Address(rawValue: self._wrapped.to) }
  public var block: UInt64 { self._wrapped.blockNumber }
  public var nonce: Decimal { Decimal(self._wrapped.nonce) }
  public var delta: Decimal { Decimal(hex: self._wrapped.delta) }
  public var status: Status { Status(rawValue: self._wrapped.status) ?? .pending}
  public var nft: NFTTransfer? {
    guard _wrapped.hasNft else { return nil }
    return self.$_nftTransfer
  }
  
  public var direction: Direction {
    if self._wrapped.from == self._wrapped.to {
      return .`self`
    } else if self._wrapped.address == self._wrapped.from {
      return .outgoing
    } else {
      return .incoming
    }
  }
  public var timestamp: Date { self._wrapped.timestamp.date }
  public var local: Bool {
    set { _wrapped.local = newValue }
    get { _wrapped.local }
  }
}

// MARK: - Transfer + MDBXObject

extension Transfer: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return TransferKey(chain: _chain, address: self.address, block: _wrapped.blockNumber, direction: self.direction, nonce: _wrapped.nonce, order: self.order ?? 0)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Transfer(serializedData: data)
    commonInit(chain: chain)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Transfer(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: chain)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Transfer(jsonString: jsonString, options: options)
    commonInit(chain: chain)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Transfer.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Transfer.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
//    let other = object as! TokenMeta
//
//    self._wrapped.contractAddress       = other._wrapped.contractAddress
//    self._wrapped.name                  = other._wrapped.name
//    self._wrapped.symbol                = other._wrapped.symbol
//    if other._wrapped.hasDecimals {
//      self._wrapped.decimals            = other._wrapped.decimals
//    }
//    if other._wrapped.hasIcon {
//      self._wrapped.icon                = other._wrapped.icon
//    }
//    if other._wrapped.hasPrice {
//      self._wrapped.price               = other._wrapped.price
//    }
//    if other._wrapped.hasMarketCap {
//      self._wrapped.marketCap           = other._wrapped.marketCap
//    }
//    if !other._wrapped.sparkline.isEmpty {
//      self._wrapped.sparkline           = other._wrapped.sparkline
//    }
//    if other._wrapped.hasVolume24H {
//      self._wrapped.volume24H           = other._wrapped.volume24H
//    }
  }
}

// MARK: - _Transfer + ProtoWrappedMessage

extension _Transfer: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Transfer {
    var transfer = Transfer(self, chain: chain)
    transfer.commonInit(chain: chain)
    return transfer
  }
}

// MARK: - Transfer + Equitable

public extension Transfer {
  static func ==(lhs: Transfer, rhs: Transfer) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Transfer + ProtoWrapper

extension Transfer: ProtoWrapper {
  init(_ wrapped: _Transfer, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    commonInit(chain: chain)
  }
}

// MARK: - Transfer + Comparable

extension Transfer: Comparable {
  public static func < (lhs: Transfer, rhs: Transfer) -> Bool {
    let lhsKey = lhs.key.key
    let rhsKey = rhs.key.key
    guard lhsKey.count == rhsKey.count else {
      return false
    }
    
    for i in 0..<lhsKey.count {
      let lhsByte = lhsKey[i]
      let rhsByte = rhsKey[i]
      if lhsByte != rhsByte {
        return lhsByte < rhsByte
      }
    }
    return false
  }
}

// MARK: - Transfer + CommonInit

extension Transfer {
  mutating func commonInit(chain: MDBXChain) {
    // Wrappers
    __nftTransfer.chain = chain
    __nftTransfer.wrappedValue = _wrapped.nft
    
    self.populateDB()
  }
  
  func populateDB() {
    __nftTransfer.database = database
  }
}
