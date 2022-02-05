//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation
import mdbx_ios

public class MDBXObject: Codable {
  weak var database: WalletDB?
  
  init() {
  }
  
  required public init(from decoder: Decoder) throws {
  }
  
  public func encode(to encoder: Encoder) throws {
  }
}
