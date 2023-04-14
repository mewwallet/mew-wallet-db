//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

// chain + timestamp + index
public final class MarketMoversItemKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain  { MDBXChain(rawValue: self._chain) }
  public var timestamp: Date { return _timestamp }
  public var index: UInt64     { return _index }

  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _timestampRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.timestamp }()
  private lazy var _timestamp: Date = {
    let value = key[_timestampRange].bytes.withUnsafeBufferPointer {
      $0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1, {
        $0.pointee
      })
    }
    let timestamp = UInt64(bigEndian: value)
    return Date(timeIntervalSince1970: TimeInterval(timestamp))
  }()
    
  private lazy var _indexRange: Range<Int> = { _timestampRange.endIndex..<_timestampRange.upperBound+MDBXKeyLength.index }()
  private lazy var _index: UInt64 = {
    let value = key[_indexRange].bytes.withUnsafeBufferPointer {
      $0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1, {
        $0.pointee
      })
    }
    return UInt64(bigEndian: value)
  }()

  // MARK: - Lifecycle
  
  public init(
    chain: MDBXChain,
    timestamp: Date,
    index: UInt64
  ) {
    let chainPart     = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let timestampPart = withUnsafeBytes(of: UInt64(timestamp.timeIntervalSince1970).bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.timestamp)
    let indexPart     = withUnsafeBytes(of: index.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.index)
    
    self.key = chainPart + timestampPart + indexPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.marketMoversItem else { return nil }
    self.key = data
  }
}
