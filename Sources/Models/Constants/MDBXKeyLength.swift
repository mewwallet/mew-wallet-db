//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/24/21.
//

import Foundation

public enum MDBXKeyLength {
  public static let chain                 = 16
  public static let contractAddress       = 20
  public static let address               = 20
  public static let order                 = 2
  public static let hash                  = 32
  public static let uuid                  = 8
  
  public static var tokenMeta:            Int { return chain + contractAddress }
  public static var orderedDexItem:       Int { return chain + order + contractAddress }
  public static var rawTransaction:       Int { return chain + hash }
  public static var token:                Int { return chain + address + contractAddress }
  public static var dAppRecord:           Int { return chain + hash + uuid }
  public static var dAppRecordReference:  Int { return chain + order }
  public static var dAppRecordMeta:       Int { return chain + hash }
  public static var dAppRecordHistory:    Int { return chain + hash }
  public static var nftAsset:             Int { return token + hash }
  
  // TODO: Needs to be refactored in future

  public static let blockNumber = 8
  public static let direction = 1
  public static let nonce = 12
  
  public static var transfer: Int {
    return chain + address + blockNumber + direction + nonce + order
  }
}
