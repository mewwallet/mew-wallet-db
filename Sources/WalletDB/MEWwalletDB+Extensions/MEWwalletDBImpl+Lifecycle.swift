//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import os
import Combine
#if canImport(UIKit)
import UIKit
#endif

public extension MEWwalletDBImpl {
  func start(path: String, tables: [MDBXTableName], readOnly: Bool) throws {
    let started = self.started.write {
      let oldValue = $0
      $0 = true
      return oldValue
    }
    guard !started else { return }
    self.path.value = path
    self.tableNames.value = tables
    
    Logger.debug(.lifecycle, "Database path: \(path)")
    
    try self.prepareEnvironment(path: path, tables: tables, readOnly: readOnly)
    
    #if os(iOS)
    NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink {[weak self] _ in
        self?.dropEnvironment()
      }
      .store(in: &cancellable.value)
    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .sink {[weak self] _ in
        try? self?.prepareEnvironment(path: path, tables: tables, readOnly: readOnly)
      }
      .store(in: &cancellable.value)
    #endif
  }
  
  func stop() {
    self.dropEnvironment()
  }
  
  // MARK: - Internal
  
  internal func getEnvironment() throws -> MEWwalletDBEnvironment {
    if let environment = self.environment {
      return environment
    } else {
      throw MEWwalletDBError.backgroundState
    }
  }
  
  // MARK: - Private
  
  private func prepareEnvironment(path: String, tables: [MDBXTableName], readOnly: Bool) throws {
    guard self.environment == nil else { return }
    do {
      let environment = try MEWwalletDBEnvironment(path: path, tables: tables, readOnly: readOnly)
      self.environment = environment
    } catch MDBXError.EACCESS {
      Logger.critical(.lifecycle, "Prepare environment error: \(MDBXError.EACCESS.localizedDescription). Recovering")
      try? FileManager.default.removeItem(atPath: path)
      do {
        try self.prepareEnvironment(path: path, tables: tables, readOnly: readOnly)
      } catch {
        Logger.critical(.lifecycle, "Prepare environment error: \(error.localizedDescription)")
        throw error
      }
    } catch {
      Logger.critical(.lifecycle, "Prepare environment error: \(error.localizedDescription)")
      throw error
    }
  }
  
  private func dropEnvironment() {
    self.environment = nil
  }
}
