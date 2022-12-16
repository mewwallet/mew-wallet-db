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
  public var chain: MDBXChain { .universal }
  public var urlHash: Data { return self._hash }
  public var uuid: UInt64 { return self._uuid }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  
  private lazy var _hashRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.hash }()
  private lazy var _hash: Data = {
    return key[_hashRange]
  }()
  
  private lazy var _uuidRange: Range<Int> = { _hashRange.endIndex..<_hashRange.upperBound+MDBXKeyLength.uuid }()
  private lazy var _uuid: UInt64 = {
    let value = key[_uuidRange].bytes.withUnsafeBufferPointer {
      $0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1, {
        $0.pointee
      })
    }
    return UInt64(bigEndian: value)
  }()
  
  // MARK: - Lifecycle
  
  public init(hash: Data, uuid: UInt64) {
    let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    let uuidPart            = withUnsafeBytes(of: uuid.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.uuid)
    
    self.key = chainPart + hashPart + uuidPart
  }
  
  public convenience init(url: URL, uuid: UInt64) {
    self.init(hash: url.sha256, uuid: uuid)
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecord else { return nil }
    self.key = data
  }
}
