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
    public let chain: MDBXChain
    public let address: Address
    public let timestamp: Date
    
    // MARK: - Lifecycle
    
    public init(chain: MDBXChain, address: Address, timestamp: Date) {
      let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
      
      let seconds             = UInt32(timestamp.timeIntervalSince1970)
      let timestampPart       = withUnsafeBytes(of: seconds.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestamp)
      
      let key = chainPart + addressPart + timestampPart
      self.key = key
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
      let _timestampRange: Range<Int> = _addressRange.endIndex..<key.count
      
      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()
      
      self.address = {
        return Address(rawValue: key[_addressRange].hexString)
      }()
      
      self.timestamp = {
        let value = key.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt32.self) }
        let seconds = TimeInterval(UInt32(bigEndian: value))
        return Date(timeIntervalSince1970: seconds)
      }()
    }
    
    public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
      let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
      
      let timestampPart: Data
      if lowerRange {
        timestampPart         = Data().setLengthLeft(MDBXKeyLength.timestamp)
      } else {
        timestampPart         = Data(repeating: 0xFF, count: MDBXKeyLength.timestamp)
      }
      let key = chainPart + addressPart + timestampPart
      self.key = key
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
      let _timestampRange: Range<Int> = _addressRange.endIndex..<key.count
      
      self.chain = {
        return MDBXChain(rawValue: key[_chainRange])
      }()
      
      self.address = {
        return Address(rawValue: key[_addressRange].hexString)
      }()
      
      self.timestamp = {
        let value = key.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt32.self) }
        let seconds = TimeInterval(UInt32(bigEndian: value))
        return Date(timeIntervalSince1970: seconds)
      }()
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.staked else { return nil }
      self.key = data
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
      let _timestampRange: Range<Int> = _addressRange.endIndex..<key.count
      
      self.chain = {
        return MDBXChain(rawValue: data[_chainRange])
      }()
      
      self.address = {
        return Address(rawValue: data[_addressRange].hexString)
      }()
      
      self.timestamp = {
        let value = data.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt32.self) }
        let seconds = TimeInterval(UInt32(bigEndian: value))
        return Date(timeIntervalSince1970: seconds)
      }()
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
