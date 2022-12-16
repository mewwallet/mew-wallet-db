//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/16/22.
//

import Foundation

public final class DAppRecordHistoryKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { .universal }
  public var urlHash: Data { return self._hash }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  
  private lazy var _hashRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash }()
  private lazy var _hash: Data = {
    return key[_hashRange]
  }()
  
  // MARK: - Lifecycle
  
  public init(hash: Data) {
    let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + hashPart
  }
  
  public convenience init(url: URL) {
    self.init(hash: url.sanitized?.sha256 ?? url.sha256)
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordHistory else { return nil }
    self.key = data
  }
}
