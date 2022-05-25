//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation
import SwiftProtobuf

protocol ProtoWrapper {
  associatedtype T: SwiftProtobuf.Message
  
  var _wrapped: T { get }
  var _chain: MDBXChain { get }
  
  init(_ wrapped: T, chain: MDBXChain)
}
