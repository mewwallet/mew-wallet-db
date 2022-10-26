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
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var address: Address { return self._address }
  public var transactionID: String { return self._transactionID }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
  private lazy var _address: Address = {
    return Address(rawValue: key[_addressRange].hexString)
  }()
  
  private lazy var _transactionIDRange: Range<Int> = { _addressRange.endIndex..<key.count }()
  private lazy var _transactionID: String = {
    return key[_transactionIDRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, account: Address, transactionID: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: account.rawValue).setLengthLeft(MDBXKeyLength.address)
    let transactionIDPart   = Data(hex: transactionID).setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + addressPart + transactionIDPart
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let transactionIDPart: Data
    if lowerRange {
      transactionIDPart     = Data().setLengthLeft(MDBXKeyLength.hash)
    } else {
      transactionIDPart     = Data(repeating: 0xFF, count: MDBXKeyLength.hash)
    }
    self.key = chainPart + addressPart + transactionIDPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.historySwap else { return nil }
    self.key = data
  }
}

// MARK: - HistoryPurchaseKey + Range

extension HistoryPurchaseKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = HistoryPurchaseKey(chain: .eth, address: address, lowerRange: true)
    let end = HistoryPurchaseKey(chain: .eth, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
