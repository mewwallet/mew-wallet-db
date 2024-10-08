//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/16/22.
//

import Foundation

public final class DAppRecordMetaKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain = .universal
  public let urlHash: Data
  
  // MARK: - Lifecycle
  
  public init(hash: Data) {
    let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash
    
    self.urlHash = {
      return key[_hashRange]
    }()
  }
  
  public convenience init(url: URL) {
    self.init(hash: url.hostURL?.sanitized?.sha256 ?? url.sanitized?.sha256 ?? url.sha256)
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordMeta else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash
    
    self.urlHash = {
      return data[_hashRange]
    }()
  }
}
