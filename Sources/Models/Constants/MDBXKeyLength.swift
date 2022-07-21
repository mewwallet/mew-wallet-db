//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/24/21.
//

import Foundation

public enum MDBXKeyLength {
  public static let chain                 = 16
  public static let address               = 20
  public static let order                 = 2
  public static let hash                  = 32
  public static let uuid                  = 8
  public static let name                  = 8
  
  public static var account:              Int { return chain + address }                          // 36
  public static var tokenMeta:            Int { return chain + address }                          // 36
  public static var orderedDexItem:       Int { return chain + order + address }                  // 38
  public static var rawTransaction:       Int { return chain + hash }                             // 48
  public static var token:                Int { return chain + address + address }                // 56
  public static var dAppRecord:           Int { return chain + hash + uuid }                      // 56
  public static var dAppRecordReference:  Int { return chain + order }                            // 18
  public static var dAppRecordMeta:       Int { return chain + hash }                             // 48
  public static var dAppRecordHistory:    Int { return chain + hash }                             // 48
  
  // TODO: Needs to be refactored in future

  public static let blockNumber = 8
  public static let direction = 1
  public static let nonce = 12
  
  public static var transfer: Int {
    return chain + address + blockNumber + direction + nonce + order
  }
}
