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
  public let chain: MDBXChain = .evm
  public let urlHash: Data
  
  // MARK: - Lifecycle
  
  public init(hash: Data) {
    let hashPart            = hash.setLengthLeft(MDBXKeyLength.hash)
    
    let coder = MDBXKeyCoder()
    self.key = coder.encode(fields: [
      MDBXChain.evm,
      hashPart
    ])
    self.urlHash = hashPart
  }
  
  public convenience init(url: URL) {
    self.init(hash: url.hostURL?.sanitized?.sha256 ?? url.sanitized?.sha256 ?? url.sha256)
  }
  
  public init?(data: Data) {
    do {
      let coder = MDBXKeyCoder()
      let decoded = try coder.decode(data: data, fields: [
        .chain,
        .rawData(count: MDBXKeyLength.hash)
      ])
      self.key = data
      
      self.urlHash = decoded[1] as! Data
    } catch {
      return nil
    }
  }
}
