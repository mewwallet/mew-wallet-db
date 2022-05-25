//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios
import OSLog
import Combine
#if canImport(UIKit)
import UIKit
#endif

public extension MEWwalletDBImpl {
  func start(path: String, tables: [MDBXTableName]) throws {
    guard !self.started else { return }
    self.started = true
    self.path = path
    self.tableNames = tables
    
    os_log("Database path: %{private}@", log: .info(.lifecycle), type: .info, path)
    
    self.prepareEnvironment(path: path, tables: tables)
    
    #if os(iOS)
    NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink {[weak self] _ in
        self?.dropEnvironment()
      }
      .store(in: &cancellable)
    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .sink {[weak self] _ in
        self?.prepareEnvironment(path: path, tables: tables)
      }
      .store(in: &cancellable)
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
  
  private func prepareEnvironment(path: String, tables: [MDBXTableName]) {
    guard self.environment == nil else { return }
    do {
      let environment = try MEWwalletDBEnvironment(path: path, tables: tables)
      self.environment = environment
    } catch {
      os_log("Prepare environment error: %{private}@", log: .error(.lifecycle), type: .fault, error.localizedDescription)
    }
  }
  
  private func dropEnvironment() {
    self.environment = nil
  }
}
