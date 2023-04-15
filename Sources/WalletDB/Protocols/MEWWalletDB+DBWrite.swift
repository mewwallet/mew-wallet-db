//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import Combine

public enum DBWriteError: Error {
  case badMode
}

public struct DBWriteMode: OptionSetAssociated {
  public var store: [UInt8 : MDBXKeyRange]
  public typealias AT = MDBXKeyRange
  
  /*
   * +----------+----------+-----------+----------+
   * |          |  APPEND  |  OVERRIDE |  CHANGES |
   * +----------+----------+-----------+----------+
   * | APPEND   |   new    |    all    |    new   |
   * +----------+----------+-----------+----------+
   * | OVERRIDE |   all    |   exist   |  changes |
   * +----------+----------+-----------+----------+
   * | CHANGES  |   new    |  changes  |  nothing |
   * +----------+----------+-----------+----------+
   *
   * all: append + override changes
   */
  
  /// Option to write new objects
  /// - mask: 0b00000001
  public static let append                              = DBWriteMode(rawValue: 1 << 0)
  /// Option to override existing objects
  /// - mask: 0b00000010
  public static let override                            = DBWriteMode(rawValue: 1 << 1)
  /// Option to override changed only objects
  /// - mask: 0b00000100
  public static let changes                             = DBWriteMode(rawValue: 1 << 2)
  /// Option to merge changes instead of replacing
  /// - mask: 0b00001100
  public static let merge                               = DBWriteMode(rawValue: 3 << 2)
  /// Option to drop table before save
  /// - mask: 0b10000000
  public static let dropTable                           = DBWriteMode(rawValue: 1 << 7)
  /// Option to maintain table data, it will remove old records and insert/update new records
  /// **Note:** this option is available only for write-array methods
  /// - mask: 0b01000000
  static let diff                                       = DBWriteMode(rawValue: 1 << 6)
  /// Write all objects
  /// - mask: 0b00000011
  public static let `default`: DBWriteMode              = [.append, .override, .merge]
  /// Append new and override changes after merge
  /// - mask: 0b00001111
  public static let appendOverrideMerge: DBWriteMode    = [.append, .override, .changes, .merge]
  /// Override changes only
  /// - mask: 0b00000110
  public static let overrideChanges: DBWriteMode        = [.override, .changes]

  public let rawValue: UInt8
  
  public init(rawValue: UInt8) {
    self.rawValue = rawValue
    store = [:]
  }
}

extension DBWriteMode {
  public static func recommended(_ table: MDBXTableName) -> DBWriteMode {
    switch table {
    case .account:            return .appendOverrideMerge
    case .dex:                return .appendOverrideMerge
    case .orderedDex:         return .appendOverrideMerge
    case .featuredDex:        return .appendOverrideMerge
    case .tokenMeta:          return .appendOverrideMerge
    case .token:              return .default
    case .rawTransaction:     return .default
    case .dappRecord:         return .appendOverrideMerge
    case .dappRecordRecent:   return .appendOverrideMerge
    case .dappRecordFavorite: return .appendOverrideMerge
    case .dappRecordMeta:     return .default
    case .dappRecordHistory:  return .appendOverrideMerge
    case .nftCollection:      return .appendOverrideMerge
    case .nftAsset:           return .appendOverrideMerge
    case .transfer:           return .appendOverrideMerge
    case .historySwap:        return .appendOverrideMerge
    case .historyPurchase:    return .appendOverrideMerge
    case .profile:            return .appendOverrideMerge
    case .staked:             return .appendOverrideMerge
    }
  }
  
  public static func diff(range: MDBXKeyRange) -> DBWriteMode {
    return DBWriteMode(rawValue: 1 << 6, value: range)
  }
}

public protocol DBWrite {
  var canWrite: AnyPublisher<Bool, Never> { get }
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode) async throws -> Int
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
}
