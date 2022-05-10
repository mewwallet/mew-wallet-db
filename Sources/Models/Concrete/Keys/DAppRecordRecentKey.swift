//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation

public final class DAppRecordRecentKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var timestamp: TimeInterval { return self._timestamp }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    key[_chainRange]
  }()
  
  private lazy var _timestampRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.timestamp }()
  private lazy var _timestamp: TimeInterval = {
    let value = key[_timestampRange].bytes.withUnsafeBufferPointer {
      $0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1, {
        $0.pointee
      })
    }
    let seconds = UInt64(bigEndian: value)
    return TimeInterval(seconds)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, timestamp: TimeInterval) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let timestampPart       = withUnsafeBytes(of: UInt64(timestamp).bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestamp)
    
    self.key = chainPart + timestampPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordRecent else { return nil }
    self.key = data
  }
}
