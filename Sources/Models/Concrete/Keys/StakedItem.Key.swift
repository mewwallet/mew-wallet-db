//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/6/23.
//

import Foundation
import mew_wallet_ios_extensions

extension StakedItem {
  public final class Key: MDBXKey {
    // MARK: - Public
    
    public let key: Data
    public var chain: MDBXChain { MDBXChain(rawValue: _chain) }
    public var address: Address { _address }
    public var timestamp: Date { _timestamp }
    
    // MARK: - Private
    
    private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
    private lazy var _chain: Data = {
      return key[_chainRange]
    }()
    
    private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
    private lazy var _address: Address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    private lazy var _timestampRange: Range<Int> = { _addressRange.endIndex..<key.count }()
    private lazy var _timestamp: Date = {
      let value = key[_timestampRange].withUnsafeBytes { $0.load(as: UInt32.self) }
      let seconds = TimeInterval(UInt32(bigEndian: value))
      return Date(timeIntervalSince1970: seconds)
    }()
    
    // MARK: - Lifecycle
    
    public init(chain: MDBXChain, address: Address, timestamp: Date) {
      let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
      
      let seconds             = UInt32(timestamp.timeIntervalSince1970)
      let timestampPart       = withUnsafeBytes(of: seconds.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestamp)
      
      self.key = chainPart + addressPart + timestampPart
    }
    
    public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
      let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
      
      let timestampPart: Data
      if lowerRange {
        timestampPart         = Data().setLengthLeft(MDBXKeyLength.timestamp)
      } else {
        timestampPart         = Data(repeating: 0xFF, count: MDBXKeyLength.timestamp)
      }
      self.key = chainPart + addressPart + timestampPart
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.staked else { return nil }
      self.key = data
    }
  }
}

// MARK: - StakedItem.Key + Range

extension StakedItem.Key {
  public static func range(chain: MDBXChain, address: Address, limit: UInt? = nil) -> MDBXKeyRange {
    let start = StakedItem.Key(chain: chain, address: address, lowerRange: true)
    let end = StakedItem.Key(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
