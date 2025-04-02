//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

final class MDBXKeyCoder {
  enum Error: Swift.Error {
    case outOfBounds
  }
  enum Field {
    case chain
    case network
    case legacyAddress
    case address
    case order
    case rawData(count: Int)
  }
  
  func encode(fields: [any MDBXKeyComponent]) -> Data {
    return fields.reduce(Data()) { partialResult, field in
      return partialResult + field.encodedData
    }
  }
  
  func decode(data: Data, fields: [Field]) throws -> [any MDBXKeyComponent] {
    var decoded: [any MDBXKeyComponent] = []
    
    var offset: Int = 0
    
    for field in fields {
      switch field {
      case .chain:
        let range = offset..<MDBXKeyLength.chain
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(MDBXChain(encodedData: data[range]))
        offset += MDBXKeyLength.chain
      case .network:
        let range = offset..<MDBXKeyLength.chain
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(MDBXChain(networkRawValue: data[range]))
        offset += MDBXKeyLength.chain
      case .address:
        let countRange = offset+1..<offset+2
        guard countRange.upperBound <= data.count else { throw Error.outOfBounds }
        let countData = data[offset+1...offset+2]
        let count = {
          let value = countData.withUnsafeBytes { $0.loadUnaligned(as: UInt16.self) }
          let uint = UInt16(bigEndian: value)
          return Int(uint)
        }()
        let range = offset..<(offset + 3 + count)
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(Address(encodedData: data[range]))
        offset += count + 3
      case .legacyAddress:
        let range = offset..<(offset + MDBXKeyLength.legacyEVMAddress)
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(Address(encodedData: data[range]))
        offset += MDBXKeyLength.legacyEVMAddress
      case .order:
        let range = offset..<(offset + MDBXKeyLength.order)
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(UInt16(encodedData: data[range]))
        offset += MDBXKeyLength.order
      case .rawData(let count):
        let range = offset..<(offset + count)
        guard range.upperBound <= data.count else { throw Error.outOfBounds }
        decoded.append(Data(encodedData: data[range]))
        offset += count
      }
    }
    
    return decoded
  }
  
  func decodeSingle<T: MDBXKeyComponent>(data: Data, field: Field) throws -> T {
    switch field {
    case .chain:
      let range = 0..<MDBXKeyLength.chain
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return MDBXChain(encodedData: data[range]) as! T
    case .network:
      let range = 0..<MDBXKeyLength.chain
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return MDBXChain(networkRawValue: data[range]) as! T
    case .address:
      let countRange = 0...1
      guard countRange.upperBound <= data.count else { throw Error.outOfBounds }
      let countData = data[countRange]
      let count = {
        let value = countData.withUnsafeBytes { $0.loadUnaligned(as: UInt16.self) }
        let uint = UInt16(bigEndian: value)
        return Int(uint)
      }()
      let range = 0..<(3 + count)
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return Address(encodedData: data[range]) as! T
    case .legacyAddress:
      let range = 0..<(MDBXKeyLength.legacyEVMAddress)
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return Address(encodedData: data[range]) as! T
    case .order:
      let range = 0..<MDBXKeyLength.order
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return UInt16(encodedData: data[range]) as! T
    case .rawData(let count):
      let range = 0..<count
      guard range.upperBound <= data.count else { throw Error.outOfBounds }
      return Data(encodedData: data[range]) as! T
    }
  }
}
