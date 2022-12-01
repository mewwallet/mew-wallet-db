//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/30/22.
//

import Foundation

extension Profile {
  public struct Status: MDBXBackedObject {
    public struct Product {
      public let product_id: String
      public let trial: Bool
    }
    
    public enum Status: Equatable {
      case inactive
      case trial
      case paid
      case expired
      case unknown(String)
      
      init(_ rawValue: String) {
        switch rawValue.lowercased() {
        case "inactive":            self = .inactive
        case "trial":               self = .trial
        case "paid":                self = .paid
        case "expired":             self = .expired
        default:                    self = .unknown(rawValue)
        }
      }
      
      var rawValue: String {
        switch self {
        case .inactive:             return "INACTIVE"
        case .trial:                return "TRIAL"
        case .paid:                 return "PAID"
        case .expired:              return "EXPIRED"
        case .unknown(let status):  return status.uppercased()
        }
      }
      
      public var isActive: Bool {
        return self == .paid || self == .trial
      }
    }
    
    public weak var database: WalletDB?
    var _chain: MDBXChain
    var _wrapped: _Profile._Status
  }
}

// MARK: - Profile.Status + Properties

extension Profile.Status {
  
  // MARK: - Properties
  
  public var last_update: Date { _wrapped.lastUpdate.date }
  
  public var product_id: String? {
    guard _wrapped.hasProductID else { return nil }
    return _wrapped.productID
  }
  
  public var start: Date? {
    guard _wrapped.hasStart else { return nil }
    return _wrapped.start.date
  }
  
  public var expiration: Date? {
    guard _wrapped.hasExpiration else { return nil }
    return _wrapped.expiration.date
  }
  
  public var checksum: String { _wrapped.checksum }
  
  public var status: Status { Status(_wrapped.status) }
  
  public var products: [Product] { _wrapped.products.map { Product(product_id: $0.productID, trial: $0.trial) } }
  
  public func isValid(_ hasher: @escaping (String) -> String) -> Bool {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]
    
    let lastUpdate = dateFormatter.string(from: _wrapped.lastUpdate.date)
    let status = _wrapped.status
    if self.status.isActive {
      guard _wrapped.hasExpiration else { return false }
      guard _wrapped.hasProductID else { return false }
      let expires = dateFormatter.string(from: _wrapped.expiration.date)
      let productID = _wrapped.productID
      
      let base = lastUpdate + status + expires + productID
      let checksum = hasher(base)
      return checksum == _wrapped.checksum
    } else {
      let base = lastUpdate + status
      let checksum = hasher(base)
      return checksum == _wrapped.checksum
    }
  }
}

// MARK: - _Profile._Status + ProtoWrappedMessage

extension _Profile._Status: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Profile.Status {
    return Profile.Status(self, chain: chain)
  }
}

// MARK: - Profile.Status + ProtoWrapper

extension Profile.Status: ProtoWrapper {
  init(_ wrapped: _Profile._Status, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
