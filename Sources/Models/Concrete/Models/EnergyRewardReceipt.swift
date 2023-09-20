//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/13/23.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct EnergyRewardReceipt: Equatable {
  public enum PurchaseType {
    case unknown
    case consumable
    case nonconsumable
    
    init(_ type: _EnergyRewardReceipt._PurchaseType) {
      switch type {
      case .unknown:          self = .unknown
      case .consumable:       self = .consumable
      case .nonconsumable:    self = .nonconsumable
      default:                self = .unknown
      }
    }
    
    var _purchase_type: _EnergyRewardReceipt._PurchaseType {
      switch self {
      case .unknown:          return .unknown
      case .consumable:       return .consumable
      case .nonconsumable:    return .nonconsumable
      }
    }
  }
  
  public enum SpendingStatus {
    case notUsed
    case spending
    case spent
  }
  
  public weak var database: WalletDB?
  var _wrapped: _EnergyRewardReceipt
  var _chain: MDBXChain
  
  @SubProperty<_EnergyRewardReceipt._Item, EnergyRewardReceipt.Item> var _item: _EnergyRewardReceipt._Item?
  @SubProperty<_EnergyNFTTransfer, EnergyNFTTransfer> var _energyNftTransfer: _EnergyNFTTransfer?
  
  // MARK: - LifeCycle
  
  public init(uuid: String,
              purchaseType: PurchaseType,
              rewardId: String,
              item: EnergyRewardReceipt.Item,
              isSpent: Bool,
              purchaseDate: Date,
              nft: EnergyNFTTransfer?,
              database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.uuid = uuid
      $0.purchaseType = purchaseType._purchase_type
      $0.rewardID = rewardId
      $0.item = item._wrapped
      $0.isSpent = isSpent
      $0.purchaseDate = .init(date: purchaseDate)
      if let nft {
        $0.nftTx = nft._wrapped
      }
    }
    self._chain = .universal
    self.commonInit(chain: .universal)
  }
}

// MARK: - EnergyRewardReceipt + Properties

extension EnergyRewardReceipt {
  
  // MARK: - Properties
  
  public var uuid: String { _wrapped.uuid }
  public var purchaseType: PurchaseType { .init(_wrapped.purchaseType) }
  public var rewardId: String { _wrapped.rewardID }
  public var isSpent: Bool {
    set {
      _wrapped.isSpent = newValue
    }
    get {
      _wrapped.isSpent
    }
  }
  public var spendingStatus: SpendingStatus {
    guard !isSpent else { return .spent }
    let item = self.item
    switch item.type {
    case .icon: return .spent
    case .energy: return .spent
    case .nft:
      if _wrapped.hasNftTx {
        return .spending
      } else {
        return .notUsed
      }
    case .unknown:
      return .spent
    }
  }
  public var purchaseDate: Date { _wrapped.purchaseDate.date }
  
  public var item: EnergyRewardReceipt.Item {
    guard let item = self.$_item else {
      return EnergyRewardReceipt.Item(_wrapped.item, chain: .universal)
    }
    return item
  }
  public var nftTransfer: EnergyNFTTransfer? {
    set {
      if let newValue {
        _wrapped.nftTx = newValue._wrapped
        __energyNftTransfer.refreshProjected(wrapped: newValue._wrapped)
      } else {
        _wrapped.clearNftTx()
      }
    }
    get {
      self.$_energyNftTransfer
    }
  }
}

// MARK: - EnergyRewardReceipt + MDBXObject

extension EnergyRewardReceipt: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return Key(timestamp: purchaseDate)
  }
  
  public var alternateKey: MDBXKey? {
    return nil
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = .universal
    self._wrapped = try _EnergyRewardReceipt(serializedData: data)
    commonInit(chain: .universal)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _EnergyRewardReceipt(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: .universal)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _EnergyRewardReceipt(jsonString: jsonString, options: options)
    commonInit(chain: .universal)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _EnergyRewardReceipt.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _EnergyRewardReceipt.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! EnergyRewardReceipt
    
    _wrapped.uuid = other._wrapped.uuid
    _wrapped.purchaseType = other._wrapped.purchaseType
    _wrapped.rewardID = other._wrapped.rewardID
    _wrapped.item = other._wrapped.item
    if !_wrapped.isSpent {
      _wrapped.isSpent = other._wrapped.isSpent
    }
    _wrapped.purchaseDate = other._wrapped.purchaseDate
    if other._wrapped.hasNftTx {
      _wrapped.nftTx = other._wrapped.nftTx
    }
  }
}

// MARK: - _EnergyRewardReceipt + ProtoWrappedMessage

extension _EnergyRewardReceipt: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> EnergyRewardReceipt {
    var receipt = EnergyRewardReceipt(self, chain: .universal)
    receipt.commonInit(chain: .universal)
    return receipt
  }
}

// MARK: - EnergyRewardReceipt + Equitable

public extension EnergyRewardReceipt {
  static func ==(lhs: EnergyRewardReceipt, rhs: EnergyRewardReceipt) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - EnergyRewardReceipt + ProtoWrapper

extension EnergyRewardReceipt: ProtoWrapper {
  init(_ wrapped: _EnergyRewardReceipt, chain: MDBXChain) {
    self._chain = .universal
    self._wrapped = wrapped
    commonInit(chain: .universal)
  }
}

// MARK: - EnergyRewardReceipt + Comparable

extension EnergyRewardReceipt: Comparable {
  public static func < (lhs: EnergyRewardReceipt, rhs: EnergyRewardReceipt) -> Bool {
    return lhs.purchaseDate < rhs.purchaseDate
  }
}

// MARK: - EnergyRewardReceipt + CommonInit

extension EnergyRewardReceipt {
  mutating func commonInit(chain: MDBXChain) {
    // Wrappers
    __energyNftTransfer.chain = .eth
    __energyNftTransfer.wrappedValue = _wrapped.nftTx
    
    __item.chain = .universal
    __item.wrappedValue = _wrapped.item
    
    self.populateDB()
  }
  
  func populateDB() {
    __energyNftTransfer.database = database
    __item.database = database
  }
}

// MARK: - EnergyRewardReceipt + Identifiable

extension EnergyRewardReceipt: Identifiable {
  public var id: String { uuid }
}
