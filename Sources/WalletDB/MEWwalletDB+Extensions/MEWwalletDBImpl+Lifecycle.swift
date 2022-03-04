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
  private var databaseURL: URL {
    return FileManager.default.temporaryDirectory
  }
  
  func start(name: String, tables: [MDBXTableName]) throws {
    guard environment == nil else { return }
    
    let environment = MDBXEnvironment()
    try environment.create()
    try environment.setMaxReader(42)
    try environment.setMaxDatabases(42)
    
    let geometry = MDBXGeometry(
      sizeLower: -1,
      sizeNow: 1024 * 10,
      sizeUpper: 1024 * 1024 * 50,
      growthStep: 1024,
      shrinkThreshold: -1,
      pageSize: -1
    )
    #if DEBUG
    try environment.setHandleSlowReaders { (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
      os_log("===========", log: .info(.lifecycle), type: .info)
      os_log("Slow reader", log: .info(.lifecycle), type: .info)
      os_log("===========", log: .info(.lifecycle), type: .info)
      return -1
    }
    #endif
    try environment.setGeometry(geometry)
    let path = self.databaseURL.appendingPathComponent(name).path
    
    os_log("Database path: %{private}@", log: .info(.lifecycle), type: .info, path)
    
    try environment.open(path: path, flags: [.envDefaults, .noTLS], mode: .iOSPermission)
    self.environment = environment
    
    self.tables = try self.prepare(tables: tables, in: environment)
    self.writer = Writer(environment: environment)
  }
  
  func stop() {
    self.tables.removeAll()
    self.environment.close(false)
  }
  
  func delete(name: String) {
    let path = self.databaseURL.appendingPathComponent(name).path
    try? FileManager.default.removeItem(atPath: path)
  }
  
  // MARK: - Private
  
  private func prepare(tables: [MDBXTableName], in environment: MDBXEnvironment) throws -> [MDBXTableName: MDBXDatabase] {
    os_signpost(.begin, log: .info(.table), name: "prepare")
    let transaction = MDBXTransaction(environment)
    try transaction.begin(parent: nil, flags: [.readWrite])
    var dbs: [MDBXTableName: MDBXDatabase] = [:]
    do {
      for table in tables {
        os_signpost(.event, log: .info(.table), name: "prepare", "table prepare: %{private}@", table.rawValue)
        let db = MDBXDatabase()
        try db.open(transaction: transaction, name: table.rawValue, flags: .create)
        dbs[table] = db
        os_signpost(.event, log: .info(.table), name: "prepare", "table done: %{private}@", table.rawValue)
      }
      try transaction.commit()
      os_signpost(.end, log: .info(.table), name: "prepare")
    } catch {
      try transaction.abort()
      os_signpost(.end, log: .info(.table), name: "prepare", "error: %{private}@", error.localizedDescription)
      os_log("Prepare table error: %{private}@", log: .error(.table), type: .fault, error.localizedDescription)
      throw error
    }
    return dbs
  }
}
