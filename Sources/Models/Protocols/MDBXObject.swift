//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation

public protocol MDBXBackedObject: Sendable {
  var database: (any WalletDB)? { get set }
}

public protocol MDBXWrapperObject {
  init(jsonString: String, chain: MDBXChain) throws
  init(jsonData: Data, chain: MDBXChain) throws
}

public protocol MDBXObject: MDBXBackedObject {
  var serialized: Data { get throws }
  var key: any MDBXKey { get }
  var alternateKey: (any MDBXKey)? { get }
  init(serializedData: Data, chain: MDBXChain, key: Data?) throws
  init(jsonString: String, chain: MDBXChain, key: Data?) throws
  init(jsonData: Data, chain: MDBXChain, key: Data?) throws
  static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self]
  static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self]
  mutating func merge(with object: any MDBXObject)
}
 
