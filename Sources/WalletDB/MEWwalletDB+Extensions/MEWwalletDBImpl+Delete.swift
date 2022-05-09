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
  func delete(key: MDBXKey, in table: MDBXTableName) async throws -> Int {
    let db = try self.database(for: table)
    return try await self.writer.delete(key: key, in: db)
  }
}
