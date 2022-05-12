//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public protocol DBLifecycle {
  func start(path: String, tables: [MDBXTableName]) throws
  func stop()
}
