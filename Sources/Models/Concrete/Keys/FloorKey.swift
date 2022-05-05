//
//  FloorKey.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import MEWextensions

public final class FloorKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
    
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain) {
    self.key = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.token else { return nil }
    self.key = data
  }
}
