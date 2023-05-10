//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/6/23.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct StakedItem: Equatable {
  public enum Status: String {
    public enum Simplified {
      case complete
      case exited
      case sending
      case processing
      case failed
    }
    
    case created    = "CREATED"
    case submitted  = "SUBMITTED"
    case success    = "SUCCESS"
    case fail       = "FAIL"
    case deposited  = "DEPOSITED"
    case pending    = "PENDING"
    case active     = "ACTIVE"
    case exited     = "EXITED"
    case orphan     = "ORPHAN" // == EXITED
    case upgrading  = "UPGRADING"
    case exiting    = "EXITING"
    
    public init(rawValue: String) {
      switch rawValue {
      case "CREATED":   self = .created
      case "SUBMITTED": self = .submitted
      case "SUCCESS":   self = .success
      case "FAIL":      self = .fail
      case "DEPOSITED": self = .deposited
      case "PENDING":   self = .pending
      case "ACTIVE":    self = .active
      case "EXITED":    self = .exited
      case "ORPHAN":    self = .orphan
      case "UPGRADING": self = .upgrading
      case "EXITING":   self = .exiting
      default:          self = .pending
      }
    }
    
    public var simplified: Simplified {
      switch self {
      case .created:
        return .sending
      case .submitted:
        return .sending
      case .success:
        return .processing
      case .fail:
        return .failed
      case .deposited:
        return .processing
      case .pending:
        return .processing
      case .active:
        return .complete
      case .upgrading:
        return .complete
      case .orphan:
        return .exited
      case .exited:
        return .exited
      case .exiting:
        return .complete
      }
    }
  }
  
  public var database: WalletDB? {
    get { MEWwalletDBImpl.shared }
    set {}
  }
  
  var _wrapped: _StakedItem
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _account: MDBXPointer<AccountKey, Account> = .init(.account)
  @SubProperty<_StakedItemQueue, StakedItem.Queue> var _queue: _StakedItemQueue?
  @SubProperty<_StakedItemDetailedInfo, StakedItem.DetailedInfo> var _detailedInfo: _StakedItemDetailedInfo?
  
  // MARK: - LifeCycle
   
  public init() {
    self._chain = .eth
    self._wrapped = .with({ _ in })
  }
}

// MARK: - StakedItem + Properties

extension StakedItem {
  
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      let key = TokenMetaKey(chain: self.chain, contractAddress: self.chain.primary)
      return try _meta.getData(key: key, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }

  public var account: Account {
    get throws {
      let address = Address(rawValue: _wrapped.address)
      return try _account.getData(key: AccountKey(address: address), policy: .ignoreCache, chain: .universal, database: self.database)
    }
  }
  
  // MARK: - Properties

  public var chain: MDBXChain { _chain }
  public var address: Address { Address(rawValue: _wrapped.address) }
  public var requestUUID: String { _wrapped.provisioningRequestUuid }
  public var txHash: String? { _wrapped.hasHash ? _wrapped.hash : nil }
  public var apr: Decimal { _wrapped.hasApr ? (Decimal(string: _wrapped.apr) ?? .zero) : .zero }
  public var averageApr: Decimal { _wrapped.hasAverageApr ? (Decimal(string: _wrapped.averageApr) ?? .zero) : .zero }
  public var balance: Decimal { Decimal(hex: _wrapped.ethTwoBalance) }
  public var stakedBalance: Decimal { Decimal(hex: _wrapped.ethTwoStaked) }
  public var eth2addresses: [String] { _wrapped.ethTwoAddresses + _wrapped.ethTwoAddressesExited }
  public var hasSlashed: Bool {
    let requests = [
      "2f82177c-9f47-4320-8020-66315adccfa4", // 834ae4fd913e02939cc417459c90d3483abe22c2b30986b99c3fed634c12a2ce0b1aab1d6de0c6a615e3d979a966ab12
      "8894b4c9-7ee8-4137-a9db-46ae4966879e", // a9af5f66ebaf74eca4001f44cda33817e28011430259cb699fd17d42be707ffcc6cb4948a3d4f930fdfeed02cfda0c38
      "1e232512-41be-49f8-bc87-417f8bb1ee30", // 9471e4b8d75df8df2b74c755b4835feac666811374a9a3c0a16d3e7aad60dc9b67ae4498047b3fba7a51c775bb365b4e (1/3)
      "8bb0e43a-ead5-4acd-901e-ac36c61b80d2", // 93f2b37e1ab118964c7b49ed31d72e5ef93b9f5a190c87a4b1502572fff63da7c1e9a78396612c66a2cc976a4f115357
      "87a72058-d90e-445a-b597-3804d32d4588", // aa235bed229f22231f0f311362d0a3f2bde65694eb836003e1e7774333ec5485b525b6f5449a8dc1553410b07f37c6cb
      "f958b910-b10a-4f52-984f-6bd76de92df7"  // 86d3dad364a1b34910a95fdda2d2b4ece2a68c948b5e66c4fbdf2571bba2f96735cecdf93fdf2fd2ff562b1e4a9dc2ef (1/2)
    ]
    return requests.contains(self.requestUUID)
  }
  public var requiresUpgrade: Bool { _wrapped.requiresUpgrade }
  public var validatorIndexes: [UInt64] { _wrapped.validatorIndexes }
  public var status: Status { Status(rawValue: _wrapped.status) }
  public var queue: StakedItem.Queue? {
    guard _wrapped.hasQueue else { return nil }
    return self.$_queue
  }
  
  public var detailedInfo: StakedItem.DetailedInfo? { self.$_detailedInfo }
  public var timestamp: Date { self._wrapped.timestamp.date }
}

// MARK: - StakedItem + MDBXObject

extension StakedItem: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return StakedItem.Key(chain: _chain, address: self.address, timestamp: self.timestamp)
  }
  
  public var alternateKey: MDBXKey? {
    return nil
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _StakedItem(serializedData: data)
    commonInit(chain: chain, key: key)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _StakedItem(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: chain, key: key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _StakedItem(jsonString: jsonString, options: options)
    commonInit(chain: chain, key: key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _StakedItem.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _StakedItem.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! StakedItem
    
    _wrapped.address                  = other._wrapped.address
    _wrapped.provisioningRequestUuid  = other._wrapped.provisioningRequestUuid
    _wrapped.status                   = other._wrapped.status
    _wrapped.ethTwoStaked             = other._wrapped.ethTwoStaked
    _wrapped.ethTwoBalance            = other._wrapped.ethTwoBalance
    _wrapped.ethTwoEarned             = other._wrapped.ethTwoEarned
    _wrapped.ethTwoAddresses          = other._wrapped.ethTwoAddresses
    _wrapped.ethTwoExited             = other._wrapped.ethTwoExited
    _wrapped.ethTwoAddressesExited    = other._wrapped.ethTwoAddressesExited
    if other._wrapped.hasHash {
      _wrapped.hash                   = other._wrapped.hash
    }
    _wrapped.requiresUpgrade          = other._wrapped.requiresUpgrade
    if other._wrapped.hasApr {
      _wrapped.apr                    = other._wrapped.apr
    }
    if other._wrapped.hasAverageApr {
      _wrapped.averageApr             = other._wrapped.averageApr
    }
    _wrapped.timestamp                = other._wrapped.timestamp
    if other._wrapped.hasQueue {
      _wrapped.queue = other._wrapped.queue
    } else if _wrapped.hasQueue {
      _wrapped.clearQueue()
    }
    _wrapped.detailedInfo             = other._wrapped.detailedInfo
  }
}

// MARK: - _StakedItem + ProtoWrappedMessage

extension _StakedItem: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> StakedItem {
    var staked = StakedItem(self, chain: chain)
    staked.commonInit(chain: chain, key: nil)
    return staked
  }
}

// MARK: - StakedItem + Equitable

public extension StakedItem {
  static func ==(lhs: StakedItem, rhs: StakedItem) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - StakedItem + ProtoWrapper

extension StakedItem: ProtoWrapper {
  init(_ wrapped: _StakedItem, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - StakedItem + Comparable

extension StakedItem: Comparable {
  public static func < (lhs: StakedItem, rhs: StakedItem) -> Bool {
    return (lhs.key as! StakedItem.Key).timestamp < (rhs.key as! StakedItem.Key).timestamp
  }
}

// MARK: - StakedItem + Identifiable

extension StakedItem: Identifiable {
  public var id: String { _wrapped.provisioningRequestUuid }
}

// MARK: - StakedItem + Hashable {

extension StakedItem: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped)
  }
}

// MARK: - StakedItem + CommonInit

extension StakedItem {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    // Wrappers
    __queue.chain = chain
    __queue.wrappedValue = _wrapped.queue
    
    __detailedInfo.chain = chain
    __detailedInfo.wrappedValue = _wrapped.detailedInfo
    
    self.populateDB()
  }

  func populateDB() {
    __queue.database = database
  }
}
