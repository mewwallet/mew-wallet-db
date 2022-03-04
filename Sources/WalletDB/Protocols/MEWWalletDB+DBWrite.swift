//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public protocol DBWrite {
  func write(table: MDBXTableName, key: MDBXKey, value: Data, override: Bool) async throws
  func write(table: MDBXTableName, key: MDBXKey, value: MDBXObject, override: Bool) async throws
  func write(table: MDBXTableName, keysAndValues: [(MDBXKey, Data)], override: Bool) async throws
  func write(table: MDBXTableName, keysAndValues: [(MDBXKey, MDBXObject)], override: Bool) async throws
  func writeAsync(table: MDBXTableName, key: MDBXKey, value: Data, override: Bool, completion: @escaping (Bool) -> Void)
  func writeAsync(table: MDBXTableName, key: MDBXKey, value: MDBXObject, override: Bool, completion: @escaping (Bool) -> Void)
  func writeAsync(table: MDBXTableName, keysAndValues: [(MDBXKey, Data)], override: Bool, completion: @escaping (Bool) -> Void)
  func writeAsync(table: MDBXTableName, keysAndValues: [(MDBXKey, MDBXObject)], override: Bool, completion: @escaping (Bool) -> Void)
}
