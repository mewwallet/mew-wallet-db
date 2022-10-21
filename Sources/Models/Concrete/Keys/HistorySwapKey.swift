//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/3/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class HistorySwapKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var address: Address { return self._address }
  public var hash: String { return self._hash }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
  private lazy var _address: Address = {
    return Address(rawValue: key[_addressRange].hexString)
  }()
  
  private lazy var _hashRange: Range<Int> = { _addressRange.endIndex..<key.count }()
  private lazy var _hash: String = {
    return key[_hashRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, account: Address, hash: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: account.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart            = Data(hex: hash).setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + addressPart + hashPart
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart: Data
    if lowerRange {
      hashPart              = Data().setLengthLeft(MDBXKeyLength.hash)
    } else {
      hashPart              = Data(repeating: 0xFF, count: MDBXKeyLength.hash)
    }
    self.key = chainPart + addressPart + hashPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.historySwap else { return nil }
    self.key = data
  }
}

// MARK: - HistorySwapKey + Range

extension HistorySwapKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = HistorySwapKey(chain: .eth, address: address, lowerRange: true)
    let end = HistorySwapKey(chain: .eth, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
