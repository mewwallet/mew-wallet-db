//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/24/22.
//

import Foundation

import Foundation
import mew_wallet_ios_extensions

public final class HistoryPurchaseKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain = .evm
  public let address: Address
  public let transactionID: String
  
  // MARK: - Lifecycle
  
  public init(account: Address, transactionID: String) {
    let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: account.rawValue).setLengthLeft(MDBXKeyLength.address)
    let transactionIDPart   = Data(hex: transactionID).setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + addressPart + transactionIDPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _transactionIDRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.transactionID = {
      return key[_transactionIDRange].hexString
    }()
  }
  
  public init(address: Address, lowerRange: Bool) {
    let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let transactionIDPart: Data
    if lowerRange {
      transactionIDPart     = Data().setLengthLeft(MDBXKeyLength.hash)
    } else {
      transactionIDPart     = Data(repeating: 0xFF, count: MDBXKeyLength.hash)
    }
    let key = chainPart + addressPart + transactionIDPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _transactionIDRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.transactionID = {
      return key[_transactionIDRange].hexString
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.historySwap else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _transactionIDRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.address = {
      return Address(rawValue: data[_addressRange].hexString)
    }()
    
    self.transactionID = {
      return data[_transactionIDRange].hexString
    }()
  }
}

// MARK: - HistoryPurchaseKey + Range

extension HistoryPurchaseKey {
  public static func range(address: Address) -> MDBXKeyRange {
    let start = HistoryPurchaseKey(address: address, lowerRange: true)
    let end = HistoryPurchaseKey(address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
