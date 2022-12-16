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
  public var chain: MDBXChain { .universal }
  public var profileID: String { return self._profileID }
  public var deviceID: String { return self._deviceID }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  
  private lazy var _profileIDRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.chain }()
  private lazy var _profileID: String = {
    return key[_profileIDRange].hexString
  }()
  
  private lazy var _deviceIDRange: Range<Int> = { _profileIDRange.endIndex..<key.count }()
  private lazy var _deviceID: String = {
    return key[_deviceIDRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(profileID: String, deviceID: String) {
    let chainPart     = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let profileIDPart = profileID.sha256.setLengthLeft(MDBXKeyLength.hash)
    let deviceIDPart  = deviceID.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + profileIDPart + deviceIDPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.profile else { return nil }
    self.key = data
  }
}
