//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/6/22.
//

import Foundation

public protocol DBDelete {
  @discardableResult
  func delete(key: MDBXKey, in table: MDBXTableName) async throws -> Int
}
