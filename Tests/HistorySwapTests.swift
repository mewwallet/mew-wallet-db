//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/3/22.
//

import Foundation
import XCTest
@testable import mew_wallet_db
import mew_wallet_ios_extensions
import SwiftProtobuf

private let projectId = "0x00"

final class HistorySwap_tests: XCTestCase {
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
  
  func testTransfers() async {
    do {
      let history = HistorySwap(chain: .eth,
                                address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"),
                                fromToken: .primary,
                                toToken: .primary,
                                fromAmount: Decimal(123),
                                toAmount: Decimal(321),
                                status: .pending,
                                dex: "1INCH",
                                hashes: ["0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737452"])
      
      let keysAndObjects: [(MDBXKey, MDBXObject)] = [(history.key, history)]
      
      debugPrint(keysAndObjects.map({ $0.0.key.hexString }))
      try await db.write(table: .historySwap, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
      let historyFetched: [HistorySwap] = try db.fetch(range: .all(limit: 10), from: .historySwap, order: .asc)
      
      debugPrint(historyFetched)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testSort() async {
    do {
      var history = [
        HistorySwap(chain: .eth,
                    address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"),
                    fromToken: .primary,
                    toToken: .primary,
                    fromAmount: Decimal(123),
                    toAmount: Decimal(321),
                    status: .success,
                    dex: "1INCH",
                    hashes: ["0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737452"])
      ]
      try await Task.sleep(nanoseconds: 1000)
      history.append(
        HistorySwap(chain: .eth,
                    address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"),
                    fromToken: .primary,
                    toToken: .primary,
                    fromAmount: Decimal(123),
                    toAmount: Decimal(321),
                    status: .pending,
                    dex: "1INCH",
                    hashes: ["0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737453"]
                   )
      )
      try await Task.sleep(nanoseconds: 1000)
      history.append(
        HistorySwap(chain: .eth,
                    address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"),
                    fromToken: .primary,
                    toToken: .primary,
                    fromAmount: Decimal(123),
                    toAmount: Decimal(321),
                    status: .failed,
                    dex: "1INCH",
                    hashes: ["0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737454"]
                   )
      )
      try await Task.sleep(nanoseconds: 1000)
      history.append(
        HistorySwap(chain: .eth,
                    address: .unknown("0x7fb1077e28b8c771330d323dbdc42e0623e05e3d"),
                    fromToken: .primary,
                    toToken: .primary,
                    fromAmount: Decimal(123),
                    toAmount: Decimal(321),
                    status: .pending,
                    dex: "1INCH",
                    hashes: ["0x600072fb3c0ebfa3b144543aa798c67511eba647294ecfd27e2e3278c2737455"]
                   )
      )
      
      
      let keysAndObjects: [(MDBXKey, MDBXObject)] = history.map({ ($0.key, $0) })
      
      try await db.write(table: .historySwap, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])
      let historyFetched: [HistorySwap] = try db.fetch(range: .all(limit: 10), from: .historySwap, order: .asc)
      
      debugPrint(historyFetched.map({ "\($0.timestamp): \($0.status)" }))
      
      debugPrint(historyFetched.sorted().map({ "\($0.timestamp): \($0.status)" }))
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
