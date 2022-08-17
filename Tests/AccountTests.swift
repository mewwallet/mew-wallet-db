//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/8/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf

final class Account_tests: XCTestCase {
  private var db: MEWwalletDBImpl!
  
  lazy private var _path: String = {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db")
    return url.path
  }()

  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)

    try! db.start(path: self._path, tables: MDBXTableName.allCases)
  }

  override func tearDown() {
    super.tearDown()

    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func test() async {
    do {
      var account = Account(chain: .eth,
                            order: 0,
                            address: "0x00c17f958d2ee523a2206206994597c13d831ec7",
                            name: "My account",
                            source: .recoveryPhrase,
                            type: .internal,
                            derivationPath: nil,
                            anonymizedId: "anonID",
                            encryptionPublicKey: nil,
                            withdrawalPublicKey: nil,
                            isHidden: true)
      
      try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
      let accounts: [Account] = try db.fetch(range: .all, from: .account)
      XCTAssertEqual(accounts.count, 1)
      XCTAssertEqual(accounts.first, account)
      
      let key = AccountKey(chain: .eth, address: "0x00c17f958d2ee523a2206206994597c13d831ec7")
      var dbAccount: Account = try db.read(key: key, table: .account)
      XCTAssertEqual(account, dbAccount)
      
      account.name = "new name"
      try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
      dbAccount = try db.read(key: key, table: .account)
      XCTAssertEqual(account, dbAccount)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
