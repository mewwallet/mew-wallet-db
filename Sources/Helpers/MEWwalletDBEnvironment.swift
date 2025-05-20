//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/12/22.
//

@preconcurrency import mdbx_ios
import os.signpost

final class MEWwalletDBEnvironment {
  let environment: MDBXEnvironment
  let unsafeWrite: UnsafeWriter
  let writer: Writer
  
  private var tables: [MDBXTableName: MDBXDatabase]
  
  init(path: String, tables: [MDBXTableName], readOnly: Bool) throws {
    let environment = MDBXEnvironment()
    try environment.create()
    try environment.setMaxReader(42)
    try environment.setMaxDatabases(42)
    
    let geometry = MDBXGeometry(
      sizeLower: -1,
      sizeNow: -1,
      sizeUpper: 1024 * 1024 * 150,
      growthStep: 1024 * 1024,
      shrinkThreshold: -1,
      pageSize: -1
    )
    #if DEBUG
    try environment.setHandleSlowReaders { (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
      Logger.debug(service: .lifecycle,
      """
      ===========
      Slow reader
      ===========
      """
      )
      return -1
    }
    #endif
    try environment.setGeometry(geometry)
    try environment.open(path: path, flags: [.envDefaults, .noTLS], mode: readOnly ? .readOnlyPermission : .iOSPermission)
    let tables = try MEWwalletDBEnvironment.prepare(tables: tables, in: environment, readonly: readOnly)
    let unsafeWrite = UnsafeWriter(environment: environment)
    let writer = Writer(unsafeWriter: unsafeWrite)
    
    self.environment = environment
    self.unsafeWrite = unsafeWrite
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
  
  private static func prepare(tables: [MDBXTableName], in environment: MDBXEnvironment, readonly: Bool) throws -> [MDBXTableName: MDBXDatabase] {
    os_signpost(.begin, log: .signpost(.table), name: "prepare")
    let transaction = MDBXTransaction(environment)
    try transaction.begin(parent: nil, flags: [readonly ? .readOnly : .readWrite])
    var dbs: [MDBXTableName: MDBXDatabase] = [:]
    do {
      for table in tables {
        os_signpost(.event, log: .signpost(.table), name: "prepare", "table prepare: %{private}@", table.rawValue)
        let db = MDBXDatabase()
        try db.open(transaction: transaction, name: table.rawValue, flags: readonly ? .defaults : .create)
        dbs[table] = db
        os_signpost(.event, log: .signpost(.table), name: "prepare", "table done: %{private}@", table.rawValue)
      }
      try transaction.commit()
      os_signpost(.end, log: .signpost(.table), name: "prepare")
    } catch {
      try transaction.abort()
      os_signpost(.end, log: .signpost(.table), name: "prepare", "error: %{private}@", error.localizedDescription)
      Logger.critical(.table, "Prepare table error: \(error.localizedDescription)")
      throw error
    }
    return dbs
  }
}
