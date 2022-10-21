//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 8/2/22.
//

import Foundation

public struct MDBXKeyRange {
  public static var all = MDBXKeyRange(start: nil, end: nil, limit: nil)
  public static func all(limit: UInt) -> MDBXKeyRange {
    return MDBXKeyRange(start: nil, end: nil, limit: limit)
  }
  
  public let start: MDBXKey?
  public let end: MDBXKey?
  public let limit: UInt?
  
  public var isRange: Bool { end != nil }
  
  public static func with(start: MDBXKey? = nil, end: MDBXKey? = nil, limit: UInt? = nil) -> MDBXKeyRange {
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
