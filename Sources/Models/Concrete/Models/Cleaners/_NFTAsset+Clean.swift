//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation

extension _NFTAsset {
  @discardableResult
  mutating func _cleanLastSale(_ chain: MDBXChain) -> _TokenMeta? {
    guard self.hasLastSale else { return nil }
    return self.lastSale._cleanToken(chain)
  }
}

extension _NFTAssetLastSale {
  mutating func _cleanToken(_ chain: MDBXChain) -> _TokenMeta? {
    guard self.hasToken else { return nil }
    let token = self.token
    self.metaKey = token.wrapped(chain).key.key
    self.clearToken()
    return token
  }
}
