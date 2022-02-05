//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation
import MEWextensions

public class TokenMetaKey: MDBXKey {
  public let key: Data
  
  public var projectId: Data {
    return key[0..<MDBXKeyLength.projectId]
  }
  
  public var contractAddress: String {
    let keyCount = key.count
    return key[MDBXKeyLength.projectId..<keyCount].hexString
  }
  
  public init(projectId: MDBXProjectId, contractAddress: String) {
    let contractAdressData = Data(hex: contractAddress).setLengthLeft(MDBXKeyLength.contractAddress)
    
    self.key = (projectId.rawValue.setLengthLeft(MDBXKeyLength.projectId) + contractAdressData)
  }
  
  init?(data: Data) {
    guard data.count > MDBXKeyLength.projectId else { return nil }
    self.key = data
  }
  
  init(tokenMetaKey: TokenMetaKey) {
    self.key = tokenMetaKey.key
  }
}
