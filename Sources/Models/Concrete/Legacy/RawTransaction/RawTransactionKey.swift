//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation
import MEWextensions
//
//public class RawTransactionKey: MDBXKey {
//  public let key: Data
//  
//  public var projectId: Data {
//    return key[0...16]
//  }
//  
//  public var hash: String { // 32 bytes
//    let keyCount = key.count
//    return key[16..<keyCount].hexString
//  }
//  
//  public init(projectId: MDBXChain, hash: String) {
//    self.key = (projectId.rawValue.setLengthLeft(16) + Data(hex: hash))
//  }
//  
//  init(rawTransactionKey: Data) {
//    self.key = rawTransactionKey
//  }
//}
