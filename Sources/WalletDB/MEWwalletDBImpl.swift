//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/10/21.
//

import Foundation
import mdbx_ios
import Combine

public final class MEWwalletDBImpl: WalletDB {
  static weak var shared: MEWwalletDBImpl!
  
  internal var started: Bool = false
  internal var path: String = ""
  internal var tableNames: [MDBXTableName] = []
  internal var environment: MEWwalletDBEnvironment? {
    didSet {
      self._canWrite.send(self.environment != nil)
    }
  }
  
  private lazy var _canWrite: CurrentValueSubject<Bool, Never> = {
    .init(false)
  }()
  public var canWrite: AnyPublisher<Bool, Never> {
    self._canWrite.eraseToAnyPublisher()
  }
  
  internal var cancellable = Set<AnyCancellable>()
  
  public init() {
    MEWwalletDBImpl.shared = self
  }
  
  deinit {
    stop()
  }
}
