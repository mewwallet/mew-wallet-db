//
//  StakedKeyTests.swift
//  
//
//  Created by Mikhail Nikanorov on 4/6/23.
//

import XCTest
@testable import mew_wallet_db

final class StakedKeyTests: XCTestCase {
  func testInitWithChainAddressTimestamp() {
    let chain = MDBXChain.eth
    let address = Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665")
    let timestamp = Date(timeIntervalSince1970: 1680835030.123)
    
    let stakedKey = StakedKey(chain: chain, address: address, timestamp: timestamp)
    
    XCTAssertNotNil(stakedKey)
    XCTAssertEqual(stakedKey.chain, chain)
    XCTAssertEqual(stakedKey.address, address)
    XCTAssertEqual(stakedKey.timestamp.timeIntervalSince1970, 1680835030.0)
    XCTAssertEqual(stakedKey.key, Data(hex: "0x00000000000000000000000000000001ab904e350f27af4d4a70994ae1f3bbc1dafee665642f81d6"))
  }
  
  func testInitWithChainAddressTimestamp2() {
    let chain = MDBXChain.eth
    let address = Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665")
    let timestamp = Date(timeIntervalSince1970: 1680835030)
    
    let stakedKey = StakedKey(chain: chain, address: address, timestamp: timestamp)
    
    XCTAssertNotNil(stakedKey)
    XCTAssertEqual(stakedKey.chain, chain)
    XCTAssertEqual(stakedKey.address, address)
    XCTAssertEqual(stakedKey.timestamp.timeIntervalSince1970, timestamp.timeIntervalSince1970)
    XCTAssertEqual(stakedKey.key, Data(hex: "0x00000000000000000000000000000001ab904e350f27af4d4a70994ae1f3bbc1dafee665642f81d6"))
  }
  
  func testInitWithChainAddressLowerRange() {
    let chain = MDBXChain.eth
    let address = Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665")
    let lowerRange = true
    
    let stakedKey = StakedKey(chain: chain, address: address, lowerRange: lowerRange)
    
    XCTAssertNotNil(stakedKey)
    XCTAssertEqual(stakedKey.chain, chain)
    XCTAssertEqual(stakedKey.address, address)
    XCTAssertEqual(stakedKey.key, Data(hex: "0x00000000000000000000000000000001ab904e350F27aF4D4A70994AE1f3bBC1dAfEe66500000000"))
  }
  
  func testInitWithChainAddressUpperRange() {
    let chain = MDBXChain.eth
    let address = Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665")
    let lowerRange = false
    
    let stakedKey = StakedKey(chain: chain, address: address, lowerRange: lowerRange)
    
    XCTAssertNotNil(stakedKey)
    XCTAssertEqual(stakedKey.chain, chain)
    XCTAssertEqual(stakedKey.address, address)
    XCTAssertEqual(stakedKey.key, Data(hex: "0x00000000000000000000000000000001ab904e350F27aF4D4A70994AE1f3bBC1dAfEe665ffffffff"))
  }
  
  func testInitWithData() {
    let data = Data(hex: "0x00000000000000000000000000000001ab904e350f27af4d4a70994ae1f3bbc1dafee665642f81d6")
    let stakedKey = StakedKey(data: data)
    
    XCTAssertNotNil(stakedKey)
    XCTAssertEqual(stakedKey?.chain, .eth)
    XCTAssertEqual(stakedKey?.address, Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665"))
    XCTAssertEqual(stakedKey?.timestamp, Date(timeIntervalSince1970: 1680835030))
  }
  
  func testInitWithIncorrectData() {
    let data = Data(hex: "0x00000000000000000000000000000001ab904e350f27af4d4a70994a")
    let stakedKey = StakedKey(data: data)
    
    XCTAssertNil(stakedKey)
  }
  
  func testRange() {
    let chain = MDBXChain.eth
    let address = Address.unknown("0xab904e350F27aF4D4A70994AE1f3bBC1dAfEe665")
    
    let range = StakedKey.range(chain: chain, address: address)
    
    XCTAssertNotNil(range)
    XCTAssertEqual(range.start?.key, StakedKey(chain: chain, address: address, lowerRange: true).key)
    XCTAssertEqual(range.end?.key, StakedKey(chain: chain, address: address, lowerRange: false).key)
  }
}
