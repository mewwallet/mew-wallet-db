//
//  StakedTests.swift
//  
//
//  Created by Mikhail Nikanorov on 4/6/23.
//

import XCTest
@testable import mew_wallet_db

final class StakedTests: XCTestCase {
  private let testJson = """
    [{"address":"0x6a289fd5142b081e0d90b48d83dcd2029274a727","provisioning_request_uuid":"8bb0e43a-ead5-4acd-901e-ac36c61b80d2","timestamp":"2021-01-08T13:36:13.000Z","price":"1876.64","status":"EXITED","eth_two_staked":"0x0","eth_two_balance":"0x0","eth_two_earned":"0x380c2c3","eth_two_addresses":[],"eth_two_exited":"0x773594000","eth_two_addresses_exited":["0x93f2b37e1ab118964c7b49ed31d72e5ef93b9f5a190c87a4b1502572fff63da7c1e9a78396612c66a2cc976a4f115357"],"hash":"0x8e001f0ea03b1e7bc7c98294ba0ec2b1c460610e5b7d09261b8c9bd45fe60f34","requiresUpgrade":false,"apr":"0.1","current_apr":"0.2","average_apr":"0.3"}]
  """
  
  private var db: MEWwalletDBImpl!
  
  lazy private var _path: String = {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db")
    return url.path
  }()

  override func setUp() async throws {
    try await super.setUp()
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)

    try db.start(path: self._path, tables: MDBXTableName.allCases)
    
    let account = Account(order: 0,
                          address: "0x6a289fd5142b081e0d90b48d83dcd2029274a727",
                          name: "My account",
                          source: .recoveryPhrase,
                          type: .internal,
                          derivationPath: nil,
                          anonymizedId: "anonID",
                          encryptionPublicKey: nil,
                          withdrawalPublicKey: nil,
                          isHidden: true)
    
    try await db.write(table: .account, key: account.key, object: account, mode: .recommended(.account))
  }

  override func tearDown() {
    super.tearDown()

    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func testArrayFromJson() async throws {
    let objects = try Staked.array(fromJSONString: testJson, chain: .eth)
    debugPrint(objects)
    
    XCTAssertEqual(objects.count, 1)
    let stake = objects.first!
    
    XCTAssertEqual(stake.address, Address("0x6a289fd5142b081e0d90b48d83dcd2029274a727"))
    XCTAssertEqual(stake.status, .exited)
    debugPrint(stake.key.key.hexString)
    XCTAssertEqual(stake.key.key, Data(hex: "0x000000000000000000000000000000016a289fd5142b081e0d90b48d83dcd2029274a7275FF85FCD"))
  }
}
