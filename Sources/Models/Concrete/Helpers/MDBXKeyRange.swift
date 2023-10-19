//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 8/2/22.
//

import Foundation

public struct MDBXKeyRange {
  public enum Op {
    case all
    case greaterThanStart
  }
  
  public static var all = MDBXKeyRange(start: nil, end: nil, limit: nil, op: .all)
  public static func all(limit: UInt) -> MDBXKeyRange {
    return MDBXKeyRange(start: nil, end: nil, limit: limit, op: .all)
  }
  
  public let start: MDBXKey?
  public let end: MDBXKey?
  public let limit: UInt?
  public let op: Op
  
  public var isRange: Bool { end != nil }
  
  init(start: MDBXKey?, end: MDBXKey?, limit: UInt?, op: Op = .all) {
    self.start = start
    self.end = end
    self.limit = limit
    self.op = op
  }
  
  public static func with(start: MDBXKey? = nil, end: MDBXKey? = nil, limit: UInt? = nil, op: Op = .all) -> MDBXKeyRange {
    return MDBXKeyRange(start: start, end: end, limit: limit, op: op)
  }
}
