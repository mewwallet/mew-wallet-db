//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import CryptoKit

extension Data {
  var sha256: Data { Data(SHA256.hash(data: self)) }
}

