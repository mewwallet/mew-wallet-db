//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/21/21.
//

import Foundation

public class TokenKey: MDBXKey {
  public var tokenMetaKey: TokenMetaKey? {
    let data = key[MDBXKeyLength.address..<key.count]
    return .init(data: Data(data))
  }
  
  public var address: Data {
    return key[0..<MDBXKeyLength.address]
  }
  
  public let key: Data
      
  public init(
    address: Data,
    tokenMetaKey: TokenMetaKey
  ) {
    let addressData = address.setLengthLeft(MDBXKeyLength.address)
    self.key = addressData + tokenMetaKey.key
  }
  
  public init?(key: Data) {
    guard key.count == MDBXKeyLength.token else {
      return nil
    }
    
    self.key = key
  }
}
