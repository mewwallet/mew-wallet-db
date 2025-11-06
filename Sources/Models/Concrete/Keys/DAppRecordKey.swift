//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation
import CryptoKit

public final class DAppRecordKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain = .evm
  public let urlHash: Data
  public let uuid: UInt64
  
  // MARK: - Lifecycle
  
  public init(hash: Data, uuid: UInt64) {
    let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    let uuidPart            = withUnsafeBytes(of: uuid.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.uuid)
    
    let key = chainPart + hashPart + uuidPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash
    let _uuidRange: Range<Int> = _hashRange.endIndex..<_hashRange.upperBound+MDBXKeyLength.uuid
    
    self.urlHash = {
      return key[_hashRange]
    }()
    
    self.uuid = {
      var raw: UInt64 = 0
      key[_uuidRange].withUnsafeBytes { src in
        withUnsafeMutableBytes(of: &raw) { dst in
          dst.copyBytes(from: src)
        }
      }
      return UInt64(bigEndian: raw)
    }()
  }
  
  public convenience init(url: URL, uuid: UInt64) {
    self.init(hash: url.sha256, uuid: uuid)
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecord else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash
    let _uuidRange: Range<Int> = _hashRange.endIndex..<_hashRange.upperBound+MDBXKeyLength.uuid
    
    self.urlHash = {
      return data[_hashRange]
    }()
    
    self.uuid = {
      var raw: UInt64 = 0
      data[_uuidRange].withUnsafeBytes { src in
        withUnsafeMutableBytes(of: &raw) { dst in
          dst.copyBytes(from: src)
        }
      }
      return UInt64(bigEndian: raw)
    }()
  }
}
