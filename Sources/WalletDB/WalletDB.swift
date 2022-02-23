//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios

public protocol WalletDB: AnyObject {
  // MARK: - LifeCycle
  func start(databaseName: String, tables: [MDBXTable]) throws
  func stop()
  
  // MARK: - Read
  func fetchAll<T: MDBXObject>(from table: MDBXTable) throws -> [T]
  func fetchRange<T: MDBXObject>(startKey: MDBXKey, endKey: MDBXKey, table: MDBXTable) throws -> [T]

  @available(*, renamed: "read()")
  func readAsync<T: MDBXObject>(key: MDBXKey, table: MDBXTable, completionBlock: @escaping (T?) -> Void)
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable, completionBlock: @escaping (T?) -> Void)
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable) async throws -> T? 
  func read<T: MDBXObject>(key: MDBXKey, table: MDBXTable) throws -> T
  
  // MARK: - Write
  func writeAsync(table: MDBXTable, key: MDBXKey, value: Data, completionBlock: @escaping (Bool) -> MDBXWriteAction)
  func writeAsync(table: MDBXTable, key: MDBXKey, object: MDBXObject, completionBlock: @escaping (Bool) -> MDBXWriteAction)
  func write<T: Encodable>(table: MDBXTable, key: MDBXKey, value: T) throws
  func write(table: MDBXTable, key: MDBXKey, value: Data) throws
  func writeIfNotExists(table: MDBXTable, key: MDBXKey, value: Data) throws
  func writeIfNotExists<T: Encodable>(table: MDBXTable, key: MDBXKey, value: T) throws

  func commit(table: MDBXTable)

  // MARK: - Tables
  func prepareTable(table: MDBXTable, transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase
  func drop(table: MDBXTable, delete: Bool) throws
  
  // MARK: - Helpers
  func beginWriteTransaction() throws
  func beginTransaction(transaction: MDBXTransaction, readonly: Bool, flags: MDBXTransactionFlags) throws
  func prepareCursor(transaction: MDBXTransaction, database: MDBXDatabase) throws -> MDBXCursor
  func delete(databaseName: String)
}
