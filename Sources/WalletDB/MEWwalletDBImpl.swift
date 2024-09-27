//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/10/21.
//

import Foundation
import mdbx_ios
import Combine
import mew_wallet_ios_extensions

public final class MEWwalletDBImpl: WalletDB {
  static let _shared = WeakThreadSafe<MEWwalletDBImpl>(nil)
  static var shared: MEWwalletDBImpl! {
    get { _shared.value }
    set { _shared.value = newValue }
  }
  
  internal let started = ThreadSafe<Bool>(false)
  internal let path = ThreadSafe<String>("")
  internal let tableNames = ThreadSafe<[MDBXTableName]>([])
  internal let _environment = ThreadSafe<MEWwalletDBEnvironment?>(nil)
  internal var environment: MEWwalletDBEnvironment? {
    get { _environment.value }
    set {
      _environment.value = newValue
      self._canWrite.value.send(newValue != nil)
    }
  }
  
  private let _canWrite = ThreadSafe<CurrentValueSubject<Bool, Never>>(.init(false))
  public var canWrite: AnyPublisher<Bool, Never> {
    self._canWrite.value.eraseToAnyPublisher()
  }
  
  internal let cancellable = ThreadSafe<Set<AnyCancellable>>(.init())
  
  public init() {
    MEWwalletDBImpl.shared = self
  }
  
  deinit {
    stop()
  }
}
