////
////  File.swift
////  
////
////  Created by Nail Galiaskarov on 6/30/21.
////
//
//import Foundation
//
//extension Transfer: Comparable {
//  public static func < (lhs: Transfer, rhs: Transfer) -> Bool {
//    // Compare statuses. Pending always on top
//    if (lhs.isPending && rhs.isPending == false) || (lhs.isPending == false && rhs.isPending) {
//      return lhs.status < rhs.status
//    }
//    
//    return nonStatusCompare(lhs: lhs, rhs: rhs)
//  }
//  
//  public static func nonStatusCompare(lhs: Transfer, rhs: Transfer) -> Bool {
//    // BlockNumber in general means order, both pendings - means equal blocks
//    let equalBlocks = lhs.blockNumber == rhs.blockNumber
//    guard equalBlocks else {
//      return lhs.blockNumber > rhs.blockNumber
//    }
//    
//    // If both txs in the same block and owner is the same
//    if lhs.direction != .incoming, rhs.direction != .incoming {
//      let lhsAddress = lhs.ownerKey.address.lowercased()
//      let rhsAddress = rhs.ownerKey.address.lowercased()
//      if lhsAddress == rhsAddress {
//        return lhs.nonce > rhs.nonce
//      }
//    }
//    
//    // In the same block - outgoing transactions - first, others - next
//    if lhs.direction == .outgoing, rhs.direction != .outgoing {
//      return false
//    } else if lhs.direction != .outgoing, rhs.direction == .outgoing {
//      return true
//    }
//    
//    // If nothing helped - try to sort by nonce
//    let equalNonce = lhs.nonce == rhs.nonce
//    guard equalNonce else {
//      return lhs.nonce > rhs.nonce
//    }
//    
//    // If transactions in the same block - try to compare by date
//    if let leftTimestamp = lhs.timestamp, let rightTimestamp = rhs.timestamp, leftTimestamp != rightTimestamp {
//      return leftTimestamp > rightTimestamp
//    }
//    
//    // Nothing to compare, try to compare by contract address, shouldn't happens at all
//    return lhs.tokenMetaKey.contractAddress.lowercased() < rhs.tokenMetaKey.contractAddress
//  }
//  
//  /// Comparison of transactions. Uses for update transactions, that means we're comparing only txHash, from, to and owner of transaction
//  /// - Parameters:
//  ///   - lhs: left tx to complare
//  ///   - rhs: right tx to compare
//  /// - Returns: Comparison result
//  public static func == (lhs: Transfer, rhs: Transfer) -> Bool {
//    let lhsFrom = lhs.fromKey.address.lowercased()
//    let rhsFrom = rhs.fromKey.address.lowercased()
//    let lhsOwner = lhs.ownerKey.address.lowercased()
//    let rhsOwner = rhs.ownerKey.address.lowercased()
//
//    let lhsTo = lhs.toKey?.address.lowercased() ?? ""
//    let rhsTo = rhs.toKey?.address.lowercased() ?? ""
//
//    return lhs.txHash == rhs.txHash && lhsFrom == rhsFrom && lhsTo == rhsTo && lhsOwner == rhsOwner
//  }
//  
//  static func compareByContractAddress(_ lhs: Transfer, rhs: Transfer) -> Bool {
//    return lhs.tokenMetaKey.contractAddress.lowercased().compare(rhs.tokenMetaKey.contractAddress.lowercased()) == .orderedDescending
//  }
//
//}
