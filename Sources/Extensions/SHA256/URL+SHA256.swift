//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation
import CryptoKit

extension URL {
  var sha256: Data { absoluteString.sha256 }
}
