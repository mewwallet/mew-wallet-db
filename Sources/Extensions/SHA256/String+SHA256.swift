//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation
import CryptoKit

extension String {
  var sha256: Data { Data(self.utf8).sha256 }
}
