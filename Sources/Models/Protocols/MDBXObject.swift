//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation

public protocol MDBXObject {
  var database: WalletDB? { get set }
  var serialized: Data { get throws }
  var key: MDBXKey { get }
  var alternateKey: MDBXKey? { get }
  init(serializedData: Data, chain: MDBXChain, key: Data?) throws
  init(jsonString: String, chain: MDBXChain, key: Data?) throws
  init(jsonData: Data, chain: MDBXChain, key: Data?) throws
  static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self]
  static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self]
  mutating func merge(with object: MDBXObject)
}
