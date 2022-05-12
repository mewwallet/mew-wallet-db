//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import OSLog

extension MEWwalletDBImpl {
  func database(for table: MDBXTableName) throws -> MDBXTable {
    guard let db = self.tables[table] else { throw MDBXError.notFound }
    return (table, db)
  }
  
  public func drop(table: MDBXTableName, delete: Bool) async throws {
    let db = try self.database(for: table)
    try await self.writer.drop(table: db, delete: delete)
    if delete {
      self.tables.removeValue(forKey: table)
    }
  }
  
  public func recover(table: MDBXTableName) async throws {
    guard self.tables[table] == nil else { throw MDBXError.keyExist }
    let db = try await self.writer.recover(table: table)
    self.tables[table] = db
  }
}
