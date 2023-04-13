//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

// chain + index(uin32)

import mew_wallet_ios_extensions

public final class MarketCollectionItemKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var index: UInt64 { return self._index }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _indexRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.index }()
  private lazy var _index: UInt64 = {
    let value = key[_indexRange].bytes.withUnsafeBufferPointer {
      $0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1, {
        $0.pointee
      })
    }
    return UInt64(bigEndian: value)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, index: UInt64) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let indexPart           = withUnsafeBytes(of: index.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.index)
    
    self.key = chainPart + indexPart
  }
  
  public init(chain: MDBXChain, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let indexPart: Data
    if lowerRange {
      indexPart         = Data().setLengthLeft(MDBXKeyLength.index)
    } else {
      indexPart         = withUnsafeBytes(of: UInt64.max.bigEndian) {
        Data($0) }.setLengthLeft(MDBXKeyLength.index)
    }

    self.key = chainPart + indexPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.marketCollectionItem else { return nil }
    self.key = data
  }
}
