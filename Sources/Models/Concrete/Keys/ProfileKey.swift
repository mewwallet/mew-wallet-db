//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/16/22.
//

import Foundation
import CryptoKit

public final class ProfileKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain = .universal
  public let profileID: String
  public let deviceID: String
  
  // MARK: - Lifecycle
  
  public init(profileID: String, deviceID: String) {
    let chainPart     = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let profileIDPart = profileID.sha256.setLengthLeft(MDBXKeyLength.hash)
    let deviceIDPart  = deviceID.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + profileIDPart + deviceIDPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _profileIDRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.chain
    let _deviceIDRange: Range<Int> = _profileIDRange.endIndex..<key.count
    
    self.profileID = {
      return key[_profileIDRange].hexString
    }()
    
    self.deviceID = {
      return key[_deviceIDRange].hexString
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.profile else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _profileIDRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.chain
    let _deviceIDRange: Range<Int> = _profileIDRange.endIndex..<key.count
    
    self.profileID = {
      return data[_profileIDRange].hexString
    }()
    
    self.deviceID = {
      return data[_deviceIDRange].hexString
    }()
  }
}
