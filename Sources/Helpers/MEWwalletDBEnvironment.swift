//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/12/22.
//

import mdbx_ios
import OSLog

final class MEWwalletDBEnvironment {
  let environment: MDBXEnvironment
  let writer: Writer
  private var tables: [MDBXTableName: MDBXDatabase]
  
  init(path: String, tables: [MDBXTableName]) throws {
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
    try environment.open(path: path, flags: [.envDefaults, .noTLS], mode: .iOSPermission)
    let tables = try MEWwalletDBEnvironment.prepare(tables: tables, in: environment)
    let writer = Writer(environment: environment)
    
    self.environment = environment
    self.writer = writer
    self.tables = tables
  }
  
  deinit {
    self.environment.close(false)
  }
  
  func database(for table: MDBXTableName) throws -> MDBXTable {
    guard let db = self.tables[table] else { throw MDBXError.notFound }
    return (table, db)
  }
  
  func remove(table: MDBXTableName) {
    self.tables.removeValue(forKey: table)
  }
  
  func add(database: MDBXDatabase, for table: MDBXTableName) {
    self.tables[table] = database
  }
  
  func getDatabase(for key: MDBXTableName) -> MDBXDatabase? {
    return self.tables[key]
  }
  
  private static func prepare(tables: [MDBXTableName], in environment: MDBXEnvironment) throws -> [MDBXTableName: MDBXDatabase] {
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
      // FIXME: - Remove drop table
      try transaction.drop(database: dbs[.account]!, delete: false)
      debugPrint("Drop accounts")
      // ENDFIXME
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
