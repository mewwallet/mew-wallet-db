//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 7/1/21.
//

import Foundation

public enum TransferDirection: UInt8 {
  case outgoing
  case incoming
  case `self`
  
  func opposite() -> TransferDirection {
    switch self {
    case .outgoing:
      return .incoming
    case .incoming:
      return .outgoing
    case .`self`:
      return .`self`
    }
  }
}
