
//
//  TokenMetaKeyV2.swift
//
//
//  Created by Sergey Kolokolnikov on 02/28/22.
//
import Foundation

public final class TokenMetaKeyV2: MDBXKey {
  public var key: Data = Data()
  
  public var projectId: Data {
    return key[0...16]
  }
  
  public var address: String {
    let keyCount = key.count
    return key[16..<keyCount].hexString
  }
  
  public init(projectId: MDBXProjectId, address: String) {
    self.key = (projectId.rawValue.setLengthLeft(16) + Data(hex: address))
  }
  
  init(rawWithdrawResponseKey: Data) {
    self.key = rawWithdrawResponseKey
  }
  
}
