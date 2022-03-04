//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public protocol DBTable {
  func drop(table: MDBXTableName, delete: Bool) async throws
}
