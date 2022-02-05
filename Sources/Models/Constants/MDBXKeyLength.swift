//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/24/21.
//

import Foundation

public enum MDBXKeyLength {
  public static let address = 24
  public static let contractAddress = 20
  public static let projectId = 16
  
  public static let blockNumber = 8
  public static let direction = 1
  public static let nonce = 12
  public static let order = 1
  
  public static var tokenMeta: Int {
    return contractAddress + projectId
  }
  
  public static var token: Int {
    return tokenMeta + address
  }
  
  public static var transfer: Int {
    return projectId + address + blockNumber + direction + nonce + order
  }
}
