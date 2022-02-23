//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import OSLog

public extension MEWwalletDBImpl {
  func prepareTable(table: MDBXTable, transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase {
    os_signpost(.begin, log: tableLogger, name: "prepare", "table: %{private}@", table.rawValue)
    if let table = tables[table] {
      os_signpost(.end, log: tableLogger, name: "prepare", "cached")
      return table
    }
    
    var openError: Error?
    
    let db = MDBXDatabase()
    do {
      try db.open(transaction: transaction, name: table.rawValue, flags: create ? .create : .defaults)
      os_signpost(.end, log: tableLogger, name: "prepare", "done")
    } catch MDBXError.notFound where !create {
      os_signpost(.end, log: tableLogger, name: "prepare", "Prepare error: table not found nor created")
      openError = MDBXError.notFound
    } catch {
      os_signpost(.end, log: tableLogger, name: "prepare", "Error: %{private}@", error.localizedDescription)
      os_log("Prepare table error: %{private}@", log: tableLogger, type: .error, error.localizedDescription)
      openError = error
    }
    
    if let error = openError {
      throw error
    }
    
    tables[table] = db
    return db
  }
  
  func drop(table: MDBXTable, delete: Bool) throws {
    os_signpost(.begin, log: tableLogger, name: "drop", "table: %{private}@ (%d)", table.rawValue, delete)
    var dropError: Error?
    
    writeWorker.sync { [weak self] in
      do {
        guard let self = self else {
          os_signpost(.end, log: tableLogger, name: "drop", "aborted")
          return
        }
        let db = try self.prepareTable(
          table: table,
          transaction: self.writeTransaction,
          create: false
        )
        os_signpost(.event, log: tableLogger, name: "drop", "ready to drop")
        try self.writeTransaction.drop(
          database: db,
          delete: delete
        )
        os_signpost(.end, log: tableLogger, name: "drop", "dropped")
      } catch MDBXError.notFound {
        os_signpost(.end, log: tableLogger, name: "drop", "Table not found")
      } catch {
        os_signpost(.end, log: tableLogger, name: "drop", "Error: %{private}@", error.localizedDescription)
        os_log("Drop error: %{private}@", log: tableLogger, type: .error, error.localizedDescription)
        dropError = error
      }
    }
    
    if let error = dropError {
      throw error
    }
  }
}
