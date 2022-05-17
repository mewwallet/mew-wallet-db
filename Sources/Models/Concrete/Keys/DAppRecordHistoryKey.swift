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
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var urlHash: Data { return self._hash }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _hashRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash }()
  private lazy var _hash: Data = {
    return key[_hashRange]
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, hash: Data) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + hashPart
  }
  
  public convenience init(chain: MDBXChain, url: URL) {
    self.init(chain: chain, hash: url.hostURL?.sanitized?.sha256 ?? url.sanitized?.sha256 ?? url.sha256)
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordHistory else { return nil }
    self.key = data
  }
}
