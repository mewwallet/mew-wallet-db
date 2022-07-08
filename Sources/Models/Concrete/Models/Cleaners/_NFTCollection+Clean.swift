//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation

extension _NFTCollection {
  mutating func _cleanAssets() -> [_NFTAsset] {
    guard !self.assets.isEmpty else { return [] }
    let assets = self.assets
    self.assets.removeAll()
    return assets
  }
}
