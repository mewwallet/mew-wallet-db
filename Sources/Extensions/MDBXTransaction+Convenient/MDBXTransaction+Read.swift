//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mdbx_ios

extension MDBXTransaction {
  func isKeyExist(key: MDBXKey, database: MDBXDatabase) throws -> Bool {
    var key = key.key
    do {
      _ = try self.getValue(for: &key, database: database)
      return true
    } catch MDBXError.notFound {
      return false
    } catch {
      throw error
    }
  }
}
