//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation
import MEWextensions

public final class RawTransactionKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var hash: String { return self._hash }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _hashRange: Range<Int> = { _chainRange.endIndex..<key.count }()
  private lazy var _hash: String = {
    return key[_hashRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, hash: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = Data(hex: hash).setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + hashPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.rawTransaction else { return nil }
    self.key = data
  }
}
