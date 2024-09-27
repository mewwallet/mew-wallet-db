//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/6/22.
//

import Foundation
import mdbx_ios
import OSLog

public extension MEWwalletDBImpl {
  @discardableResult
  func delete(key: any MDBXKey, in table: MDBXTableName) async throws -> Int {
    let environment = try self.getEnvironment()
    guard let db = environment.getDatabase(for: table) else { throw MDBXError.notFound }
    return try await environment.writer.delete(key: key, in: (table, db))
  }
}
