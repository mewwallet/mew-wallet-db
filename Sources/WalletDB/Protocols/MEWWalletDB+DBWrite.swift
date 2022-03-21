//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation

public enum DBWriteError: Error {
  case badMode
}

public struct DBWriteMode: OptionSet {
  /*
   * +----------+----------+-----------+----------+
   * |          |  APPEND  |  OVERRIDE |  CHANGES |
   * +----------+----------+-----------+----------+
   * | APPEND   |   new    |    all    |    new   |
   * +----------+----------+-----------+----------+
   * | OVERRIDE |   all    |   exist   |  changes |
   * +----------+----------+-----------+----------+
   * | CHANGES  |   new    |  changes  |  nothing |
   * +----------+----------+-----------+----------+
   *
   * all: append + override changes
   */
  
  /// Option to write new objects
  /// - mask: 0b00000001
  public static let append                       = DBWriteMode(rawValue: 1 << 0)
  /// Option to override existing objects
  /// - mask: 0b00000010
  public static let override                     = DBWriteMode(rawValue: 1 << 1)
  /// Option to override changed only objects
  /// - mask: 0b00000100
  public static let changes                      = DBWriteMode(rawValue: 1 << 2)
  
  
  /// Write all objects
  /// - mask: 0b00000011
  public static let `default`: DBWriteMode       = [.append, .override]
  /// Override changes only
  /// - mask: 0b00000110
  public static let overrideChanges: DBWriteMode = [.override, .changes]
  /// Append new and oveerride changes
  /// - mask: 0b00000111
  public static let all: DBWriteMode             = [.append, .override, .changes]

  public let rawValue: UInt8
  
  public init(rawValue: UInt8) {
    self.rawValue = rawValue
  }
}

public protocol DBWrite {
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode) async throws -> Int
  
  @discardableResult
  func write(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode) async throws -> Int
  
  func writeAsync(table: MDBXTableName, key: MDBXKey, data: Data, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, key: MDBXKey, object: MDBXObject, mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, keysAndData: [MDBXKeyData], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
  func writeAsync(table: MDBXTableName, keysAndObjects: [MDBXKeyObject], mode: DBWriteMode, completion: @escaping (Bool, Int) -> Void)
}
