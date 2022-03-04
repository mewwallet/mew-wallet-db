////
////  File.swift
////  
////
////  Created by Nail Galiaskarov on 6/22/21.
////
//
//import Foundation
//import MEWextensions
//
//public final class RecipientKey: MDBXKey {
//  public let key: Data
//  
//  public var projectId: Data {
//    return key[0...16]
//  }
//  
//  public var address: String {
//    let keyCount = key.count
//    return key[16..<keyCount].hexString
//  }
//  
//  public init(projectId: MDBXProjectId, address: String) {
//    self.key = (projectId.rawValue.setLengthLeft(16) + Data(hex: address))
//  }
//  
//  init?(data: Data) {
//    guard data.count > 16 else { return nil }
//    self.key = data
//  }
//  
//  init(recipientKey: RecipientKey) {
//    self.key = recipientKey.key
//  }
//}
