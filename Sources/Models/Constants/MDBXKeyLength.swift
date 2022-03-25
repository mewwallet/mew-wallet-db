//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/24/21.
//

import Foundation

public enum MDBXKeyLength {
  public static let chain             = 16
  public static let contractAddress   = 20
  public static let address           = 20
  public static let order             = 2
  public static let hash              = 32
  
  public static var tokenMeta:      Int { return chain + contractAddress }
  public static var orderedDexItem: Int { return chain + order + contractAddress }
  public static var rawTransaction: Int { return chain + hash }
  public static var token:          Int { return chain + address + contractAddress }
  
  public static let blockNumber = 8
  public static let direction = 1
  public static let nonce = 12
  
  public static var transfer: Int {
    return chain + address + blockNumber + direction + nonce + order
  }
}
