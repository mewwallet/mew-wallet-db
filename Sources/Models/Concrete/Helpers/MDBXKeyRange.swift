//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 8/2/22.
//

import Foundation

public struct MDBXKeyRange {
  static var all = MDBXKeyRange(start: nil, end: nil)
  
  public let start: MDBXKey?
  public let end: MDBXKey?
  
  public var isRange: Bool { end != nil }
  
  static func with(start: MDBXKey? = nil, end: MDBXKey? = nil) -> MDBXKeyRange {
    return MDBXKeyRange(start: start, end: end)
  }
}
