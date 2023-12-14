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
    public var chain: MDBXChain = .universal
    
    // MARK: - Public
    
    public let key: Data
    public var timestamp: Date { _timestamp }
    
    // MARK: - Private
    
    private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
    
    private lazy var _timestampRange: Range<Int> = { _chainRange.endIndex..<key.count }()
    private lazy var _timestamp: Date = {
      let value = key[_timestampRange].withUnsafeBytes { $0.load(as: UInt64.self) }
      let milliseconds = UInt64(bigEndian: value)
      let seconds = TimeInterval(milliseconds / 1000)
      return Date(timeIntervalSince1970: seconds)
    }()
    
    // MARK: - Lifecycle
    
    public init(timestamp: Date) {
      let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
      
      let seconds             = UInt64(timestamp.timeIntervalSince1970 * 1000)
      let timestampPart       = withUnsafeBytes(of: seconds.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestampMilliseconds)
      
      self.key = chainPart + timestampPart
    }
    
    public init(lowerRange: Bool) {
      let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let timestampPart: Data
      if lowerRange {
        timestampPart         = Data().setLengthLeft(MDBXKeyLength.timestampMilliseconds)
      } else {
        timestampPart         = Data(repeating: 0xFF, count: MDBXKeyLength.timestampMilliseconds)
      }
      self.key = chainPart + timestampPart
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.energyReceipt else { return nil }
      self.key = data
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
