//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/2/22.
//

import Foundation
import mdbx_ios
import OSLog
import Algorithms

fileprivate struct WriterStatic {
  static let chunkSize = 50
}

actor Writer {
  private var transaction: MDBXTransaction
  
  init(environment: MDBXEnvironment) {
    self.transaction = MDBXTransaction(environment)
  }
  
  // MARK: - Write
  
  func write(table: MDBXTable, key: MDBXKey, value: Data, override: Bool) async throws {
    os_signpost(.begin, log: .info(.write), name: "write", "to table: %{private}@", table.name.rawValue)
    
    do {
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      if !override {
        guard try !self.transaction.isKeyExist(key: key, database: table.db) else {
          os_signpost(.end, log: .info(.write), name: "write", "key exist %{private}@ in table %{private}@", key.key.hexString, table.name.rawValue)
          try? self.transaction.abort()
          return
        }
      }
      try self.transaction.write(key: key, value: value, database: table.db)
      
      os_signpost(.event, log: .info(.write), name: "write", "put finished")
      try self.transaction.commit()
      
      os_signpost(.end, log: .info(.write), name: "write", "done")
    } catch {
      os_signpost(.end, log: .error(.write), name: "write", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: .error(.write), type: .error, error.localizedDescription)
      try self.transaction.abort()
    }
  }
  
  func write(table: MDBXTable, keysAndValues: [(MDBXKey, Data)], override: Bool) async throws {
    os_signpost(.begin, log: .info(.write), name: "write", "to table: %{private}@", table.name.rawValue)
    
    let chunksCount = max(keysAndValues.count / WriterStatic.chunkSize, 1)
    let chunks = keysAndValues.chunks(ofCount: chunksCount)
    
    do {
      for chunk in chunks {
        try self.transaction.begin(parent: nil, flags: [.readWrite])
        for (key, value) in chunk {
          if !override {
            guard try !self.transaction.isKeyExist(key: key, database: table.db) else {
              os_signpost(.end, log: .info(.write), name: "write", "key exist %{private}@ in table %{private}@", key.key.hexString, table.name.rawValue)
              try? self.transaction.abort()
              return
            }
          }
          try self.transaction.write(key: key, value: value, database: table.db)
        }
        
        os_signpost(.event, log: .info(.write), name: "write", "put finished")
        try self.transaction.commit()
      }
      
      os_signpost(.end, log: .info(.write), name: "write", "done")
    } catch {
      os_signpost(.end, log: .error(.write), name: "write", "Error: %{private}@", error.localizedDescription)
      os_log("Error: %{private}@", log: .error(.write), type: .error, error.localizedDescription)
      try self.transaction.abort()
    }
  }
  
  // MARK: - Drop
  
  func drop(table: MDBXTable, delete: Bool) throws {
    os_signpost(.begin, log: .info(.table), name: "drop", "table: %{private}@ (%d)", table.name.rawValue, delete)
    
    do {
      os_signpost(.event, log: .info(.table), name: "drop", "ready to drop")
      try self.transaction.begin(parent: nil, flags: [.readWrite])
      try self.transaction.drop(database: table.db, delete: delete)
      try self.transaction.commit()
      os_signpost(.end, log: .info(.table), name: "drop", "dropped")
    } catch MDBXError.notFound {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "drop", "Table not found")
    } catch {
      try? self.transaction.abort()
      os_signpost(.end, log: .info(.table), name: "drop", "Error: %{private}@", error.localizedDescription)
      os_log("Drop error: %{private}@", log: .info(.table), type: .error, error.localizedDescription)
      throw error
    }
  }
  
  // MARK:
  
//  func prepareTable(table: MDBXTable, create: Bool) throws -> MDBXDatabase {
//    os_signpost(.begin, log: tableLogger, name: "prepare", "table: %{private}@", table.rawValue)
//    if let table = tables[table] {
//      os_signpost(.end, log: tableLogger, name: "prepare", "cached")
//      return table
//    }
//
//    var openError: Error?
//
//    let db = MDBXDatabase()
//    do {
//      try db.open(transaction: self.transaction, name: table.rawValue, flags: create ? .create : .defaults)
//      os_signpost(.end, log: tableLogger, name: "prepare", "done")
//    } catch MDBXError.notFound where !create {
//      os_signpost(.end, log: tableLogger, name: "prepare", "Prepare error: table not found nor created")
//      openError = MDBXError.notFound
//    } catch {
//      os_signpost(.end, log: tableLogger, name: "prepare", "Error: %{private}@", error.localizedDescription)
//      os_log("Prepare table error: %{private}@", log: tableLogger, type: .error, error.localizedDescription)
//      openError = error
//    }
//
//    if let error = openError {
//      throw error
//    }
//
//    tables[table] = db
//    return db
//  }
  
//  func drop(table: MDBXTable, delete: Bool) throws {
//    guard let db = self.tables[table] else { throw MDBXError.notFound }
//    os_signpost(.begin, log: .info(.table), name: "drop", "table: %{private}@ (%d)", table.rawValue, delete)
//    var dropError: Error?
//
//    do {
//      os_signpost(.event, log: .info(.table), name: "drop", "ready to drop")
//      try self.transaction.drop(database: db, delete: delete )
//      os_signpost(.end, log: .info(.table), name: "drop", "dropped")
//    } catch MDBXError.notFound {
//      os_signpost(.end, log: .info(.table), name: "drop", "Table not found")
//    } catch {
//      os_signpost(.end, log: .info(.table), name: "drop", "Error: %{private}@", error.localizedDescription)
//      os_log("Drop error: %{private}@", log: .info(.table), type: .error, error.localizedDescription)
//      dropError = error
//    }
//
//    if let error = dropError {
//      throw error
//    }
//  }
  
  
  
//  func drop() {
//    os_signpost(.begin, log: tableLogger, name: "drop", "table: %{private}@ (%d)", table.rawValue, delete)
    
//    let db = try
//  }
  
//  func drop(table: MDBXTable, delete: Bool) throws {
//    os_signpost(.begin, log: tableLogger, name: "drop", "table: %{private}@ (%d)", table.rawValue, delete)
//    var dropError: Error?
//
//    writeWorker.sync { [weak self] in
//      do {
//        guard let self = self else {
//          os_signpost(.end, log: tableLogger, name: "drop", "aborted")
//          return
//        }
//        let db = try self.prepareTable(
//          table: table,
//          transaction: self.writeTransaction,
//          create: false
//        )
//        os_signpost(.event, log: tableLogger, name: "drop", "ready to drop")
//        try self.writeTransaction.drop(
//          database: db,
//          delete: delete
//        )
//        os_signpost(.end, log: tableLogger, name: "drop", "dropped")
//      } catch MDBXError.notFound {
//        os_signpost(.end, log: tableLogger, name: "drop", "Table not found")
//      } catch {
//        os_signpost(.end, log: tableLogger, name: "drop", "Error: %{private}@", error.localizedDescription)
//        os_log("Drop error: %{private}@", log: tableLogger, type: .error, error.localizedDescription)
//        dropError = error
//      }
//    }
//
//    if let error = dropError {
//      throw error
//    }
//  }
  
  // MARK: - Private
  
  private func beginWriteTransaction() throws {
    do {
      try self.transaction.begin(parent: nil, flags: [.readWrite])
    } catch {
      throw error
    }
  }
}
//  func commit(table: MDBXTable) {
//    os_signpost(.begin, log: writeLogger, name: "commit", "to table: %{private}@", table.rawValue)
//
//    writeWorker.sync { [weak self] in
//      guard let self = self else {
//        os_signpost(.end, log: writeLogger, name: "commit", "aborted")
//        return
//      }
//
//      do {
//        let _ = try self.prepareTable(table: table, transaction: self.writeTransaction, create: true)
//        try self.writeTransaction.commit()
//        os_signpost(.event, log: writeLogger, name: "commit", "commited")
//        try self.beginTransaction(transaction: self.writeTransaction)
//        os_signpost(.end, log: writeLogger, name: "commit", "re-begin transaction")
//
//      } catch {
//        os_signpost(.end, log: writeLogger, name: "commit", "Error: %{private}@", error.localizedDescription)
//        os_log("Error: %{private}@", log: writeLogger, type: .error, error.localizedDescription)
//      }
//    }
//  }
