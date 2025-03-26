//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/14/23.
//

import Foundation
import mew_wallet_ios_extensions

extension EnergyRewardReceipt {
  public final class Key: MDBXKey {    
    
    // MARK: - Public
    
    public let chain: MDBXChain = .evm
    public let key: Data
    public let timestamp: Date
    
    // MARK: - Lifecycle
    
    public init(timestamp: Date) {
      let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
      
      let seconds             = UInt64(timestamp.timeIntervalSince1970 * 1000)
      let timestampPart       = withUnsafeBytes(of: seconds.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestampMilliseconds)
      
      let key = chainPart + timestampPart
      self.key = key
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _timestampRange: Range<Int> = _chainRange.endIndex..<key.count
      
      self.timestamp = {
        let value = key.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt64.self) }
        let milliseconds = UInt64(bigEndian: value)
        let seconds = TimeInterval(milliseconds / 1000)
        return Date(timeIntervalSince1970: seconds)
      }()
    }
    
    public init(lowerRange: Bool) {
      let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let timestampPart: Data
      if lowerRange {
        timestampPart         = Data().setLengthLeft(MDBXKeyLength.timestampMilliseconds)
      } else {
        timestampPart         = Data(repeating: 0xFF, count: MDBXKeyLength.timestampMilliseconds)
      }
      let key = chainPart + timestampPart
      self.key = key
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _timestampRange: Range<Int> = _chainRange.endIndex..<key.count
      
      self.timestamp = {
        let value = key.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt64.self) }
        let milliseconds = UInt64(bigEndian: value)
        let seconds = TimeInterval(milliseconds / 1000)
        return Date(timeIntervalSince1970: seconds)
      }()
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.energyReceipt else { return nil }
      self.key = data
      
      let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
      let _timestampRange: Range<Int> = _chainRange.endIndex..<key.count
      
      self.timestamp = {
        let value = data.subdata(in: _timestampRange).withUnsafeBytes { $0.load(as: UInt64.self) }
        let milliseconds = UInt64(bigEndian: value)
        let seconds = TimeInterval(milliseconds / 1000)
        return Date(timeIntervalSince1970: seconds)
      }()
    }
  }
}

// MARK: - EnergyRewardReceipt.Key + Range

extension EnergyRewardReceipt.Key {
  public static func range(limit: UInt? = nil) -> MDBXKeyRange {
    let start = EnergyRewardReceipt.Key(lowerRange: true)
    let end = EnergyRewardReceipt.Key(lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
