//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class RawTransactionKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let hash: String
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, hash: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let hashPart            = Data(hex: hash).setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.hash = {
      return key[_hashRange].hexString
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.rawTransaction else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _hashRange: Range<Int> = _chainRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.hash = {
      return data[_hashRange].hexString
    }()
  }
}
