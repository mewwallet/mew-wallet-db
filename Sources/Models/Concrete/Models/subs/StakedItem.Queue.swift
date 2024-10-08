//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/6/23.
//

import Foundation

extension StakedItem {
  public struct Queue: MDBXBackedObject, Equatable {
    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _StakedItemQueue
  }
}

// MARK: - StakedItem.Queue + Properties

extension StakedItem.Queue {
  
  // MARK: - Properties
  
  public var position: UInt32 { _wrapped.position }
  public var total: UInt32 { _wrapped.total }
  public var behind: UInt32 { _wrapped.total > _wrapped.position ? _wrapped.total - _wrapped.position : 0 }
  public var activationTimestamp: Date { _wrapped.estimatedActivationTimestamp.date }
  public var activationComponents: DateComponents {
    let calenadar = Calendar(identifier: .gregorian)
    return calenadar.dateComponents([.day, .hour, .minute], from: Date(), to: activationTimestamp)
  }
}

// MARK: - StakedItem.Queue + Equatable

extension StakedItem.Queue {
  public static func == (lhs: StakedItem.Queue, rhs: StakedItem.Queue) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - _StakedItemQueue + ProtoWrappedMessage

extension _StakedItemQueue: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> StakedItem.Queue {
    return StakedItem.Queue(self, chain: chain)
  }
}

// MARK: - StakedItem.Queue + ProtoWrapper

extension StakedItem.Queue: ProtoWrapper {
  init(_ wrapped: _StakedItemQueue, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
