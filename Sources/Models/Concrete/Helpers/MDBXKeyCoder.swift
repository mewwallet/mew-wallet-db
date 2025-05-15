//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

final class MDBXKeyCoder {
  enum Field {
    case chain
    case network
    case legacyAddress
    case address
    case block
    case direction
    case order
    case nonce
    case rawData(count: Int)
  }
  
  func encode(fields: [any MDBXKeyComponent]) -> Data {
    return fields.reduce(Data()) { partialResult, field in
      return partialResult + field.encodedData
    }
  }
  
  func decode(data: Data, fields: [Field]) throws(DataReaderError) -> [any MDBXKeyComponent] {
    var decoded: [any MDBXKeyComponent] = []
    
    var cursor = data.startIndex
    for field in fields {
      switch field {
      case .chain:
        let encoded = try data.read(&cursor, offsetBy: MDBXKeyLength.chain)
        decoded.append(MDBXChain(encodedData: encoded))

      case .network:
        let encoded = try data.read(&cursor, offsetBy: MDBXKeyLength.chain)
        decoded.append(MDBXChain(networkRawValue: encoded))

      case .address:
        var start = cursor
        try data.seek(&cursor, offsetBy: 1)
        let count: UInt16 = try data.readBE(&cursor)
        let encoded = try data.read(&start, offsetBy: Int(count) + 3)
        try decoded.append(Address(encodedData: encoded))
        cursor = start
      
      case .legacyAddress:
        let encoded = try data.read(&cursor, offsetBy: MDBXKeyLength.legacyEVMAddress)
        try decoded.append(Address(encodedData: encoded))
        
      case .block:
        let order: UInt64 = try data.readBE(&cursor)
        decoded.append(order)
        
      case .direction:
        let encoded = try data.read(&cursor, offsetBy: MDBXKeyLength.direction)
        try decoded.append(Transfer.Direction(encodedData: encoded))
        
      case .nonce:
        let order: UInt64 = try data.readBE(&cursor)
        decoded.append(order)

      case .order:
        let order: UInt16 = try data.readBE(&cursor)
        decoded.append(order)

      case .rawData(let count):
        let raw = try data.read(&cursor, offsetBy: count)
        try decoded.append(Data(encodedData: raw))
      }
    }
    return decoded
  }
}
