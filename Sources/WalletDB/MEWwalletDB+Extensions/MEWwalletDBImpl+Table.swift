//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
@preconcurrency import mdbx_ios
import OSLog

extension MEWwalletDBImpl {
  public func drop(table: MDBXTableName, delete: Bool) async throws {
    let environment = try self.getEnvironment()
    let db = try environment.database(for: table)
    try await environment.writer.drop(table: db, delete: delete)
    if delete {
      environment.remove(table: table)
    }
  }
  
  public func recover(table: MDBXTableName) async throws {
    let environment = try self.getEnvironment()
    guard environment.getDatabase(for: table) == nil else { throw MDBXError.keyExist }
    let db = try await environment.writer.recover(table: table)
    environment.add(database: db, for: table)
  }
}
