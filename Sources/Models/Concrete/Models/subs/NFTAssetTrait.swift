//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import mew_wallet_ios_extensions

public struct NFTAssetTrait: MDBXBackedObject {
  public enum DisplayType {
    case string(String)
    case number(String)
    case percentage(Decimal)
    case date(Date)
    case unknown(String)
    init(rawValue: String, value: String) {
      switch rawValue.uppercased() {
      case "STRING":
        self = .string(value)
      case "NUMBER":
        self = .number(value)
      case "PERCENTAGE":
        guard let value = Decimal(wrapped: value, hex: false) else {
          self = .unknown(value)
          return
        }
        self = .percentage(value)
      case "DATE":
        guard let timeInterval = TimeInterval(value) else {
          self = .unknown(value)
          return
        }
        self = .date(Date(timeIntervalSince1970: timeInterval))
      case "UNKNOWN":
        self = .unknown(value)
      default:
        self = .unknown(value)
      }
    }
  }
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _NFTAssetTrait
}

// MARK: - NFTAssetTrait + Properties

extension NFTAssetTrait {
  
  // MARK: - Properties
  
  public var trait: String { _wrapped.trait }
  public var count: UInt64 { _wrapped.count }
  public var value: String { _wrapped.value }
  public var percentage: Decimal { Decimal(wrapped: _wrapped.percentage, hex: false) ?? .zero }
  public var displayValue: DisplayType { DisplayType(rawValue: _wrapped.displayType, value: _wrapped.value) }
}

// MARK: - NFTStats + Hashable

extension NFTAssetTrait: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped)
  }
}

// MARK: - NFTStats + Equatable

extension NFTAssetTrait: Equatable {
  public static func == (lhs: NFTAssetTrait, rhs: NFTAssetTrait) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTAssetTrait + ProtoSubWrappedMessage

extension _NFTAssetTrait: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTAssetTrait {
    return NFTAssetTrait(self, chain: chain)
  }
}

// MARK: - NFTAssetTrait + ProtoSubWrapper

extension NFTAssetTrait: ProtoWrapper {
  init(_ wrapped: _NFTAssetTrait, chain: MDBXChain) {
    _chain = chain
    _wrapped = wrapped
  }
}
