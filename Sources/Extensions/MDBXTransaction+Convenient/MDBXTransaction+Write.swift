//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mdbx_ios

extension MDBXTransaction {
  func write(key: MDBXKey, value: Data, database: MDBXDatabase) throws {
    guard self.flags.contains(.readWrite) else { throw MDBXError.badTransaction }
    var key = key.key
    var value = value
    
    try self.put(value: &value,
                 forKey: &key,
                 database: database,
                 flags: [.upsert])
  }
}
