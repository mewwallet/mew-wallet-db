//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/11/23.
//

import Foundation

extension StakedItem {
  public struct DetailedInfo: MDBXBackedObject, Equatable {
    public weak var database: WalletDB?
    var _chain: MDBXChain
    var _wrapped: _StakedItemDetailedInfo
  }
}

// MARK: - DetailedInfo.Queue + Properties

extension StakedItem.DetailedInfo {
  
  // MARK: - Properties
  
  public var balance: Decimal { Decimal(hex: _wrapped.ethTwoBalance) }
  public var rewardsAndFees: Decimal { Decimal(hex: _wrapped.ethTwoRewardsAndFees) }
  public var rewards: Decimal { Decimal(hex: _wrapped.ethTwoRewards) }
  public var fees: Decimal { Decimal(hex: _wrapped.ethTwoFees) }
}

// MARK: - StakedItem.DetailedInfo + Equatable

extension StakedItem.DetailedInfo {
  public static func == (lhs: StakedItem.DetailedInfo, rhs: StakedItem.DetailedInfo) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - _StakedItemDetailedInfo + ProtoWrappedMessage

extension _StakedItemDetailedInfo: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> StakedItem.DetailedInfo {
    return StakedItem.DetailedInfo(self, chain: chain)
  }
}

// MARK: - StakedItem.DetailedInfo + ProtoWrapper

extension StakedItem.DetailedInfo: ProtoWrapper {
  init(_ wrapped: _StakedItemDetailedInfo, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
