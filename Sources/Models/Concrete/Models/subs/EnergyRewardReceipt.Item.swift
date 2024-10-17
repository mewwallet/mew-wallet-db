//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/13/23.
//

import Foundation
import mew_wallet_ios_extensions

extension EnergyRewardReceipt {
  public struct Item: MDBXBackedObject {
    public enum `Type` {
      case unknown
      case icon
      case energy
      case nft
      
      init(_ type: _EnergyRewardReceipt._Item._ItemType) {
        switch type {
        case .unknown:          self = .unknown
        case .icon:             self = .icon
        case .energy:           self = .energy
        case .nft:              self = .nft
        case .UNRECOGNIZED:     self = .unknown
        }
      }
      
      var _item_type: _EnergyRewardReceipt._Item._ItemType {
        switch self {
        case .unknown:          return .unknown
        case .icon:             return .icon
        case .energy:           return .energy
        case .nft:              return .nft
        }
      }
    }
    
    public enum Payload {
      public struct NFT {
        public enum Rarity {
          case unknown
          case common
          case uncommon
          case rare
          case epic
          case legendary
          case exclusive
          
          init(_ rarity: _EnergyRewardReceipt._Item._NFT._Rarity) {
            switch rarity {
            case .unknown:        self = .unknown
            case .common:         self = .common
            case .uncommon:       self = .uncommon
            case .rare:           self = .rare
            case .epic:           self = .epic
            case .legendary:      self = .legendary
            case .exclusive:      self = .exclusive
            case .UNRECOGNIZED:   self = .unknown
            }
          }
          
          var _rarity: _EnergyRewardReceipt._Item._NFT._Rarity {
            switch self {
            case .common:         return .common
            case .uncommon:       return .uncommon
            case .rare:           return .rare
            case .epic:           return .epic
            case .legendary:      return .legendary
            case .exclusive:      return .exclusive
            case .unknown:        return .unknown
            }
          }
        }
        
        public let tokenId: Int
        public let url: URL
        public let rarity: Rarity
        
        public init(tokenId: Int, url: URL, rarity: Rarity) {
          self.tokenId = tokenId
          self.url = url
          self.rarity = rarity
        }
      }
      
      public struct Energy {
        public enum Size {
          case unknown
          case small
          case medium
          case large
          
          init(_ size: _EnergyRewardReceipt._Item._ENERGY._Size) {
            switch size {
            case .unknown:        self = .unknown
            case .small:          self = .small
            case .medium:         self = .medium
            case .large:          self = .large
            case .UNRECOGNIZED:   self = .unknown
            }
          }
          
          var _size: _EnergyRewardReceipt._Item._ENERGY._Size {
            switch self {
            case .unknown:        return .unknown
            case .small:          return .small
            case .medium:         return .medium
            case .large:          return .large
            }
          }
        }
        
        public let url: URL
        public let amount: Decimal
        public let size: Size
        
        public init(url: URL, amount: Decimal, size: Size) {
          self.url = url
          self.amount = amount
          self.size = size
        }
      }
      
      public struct Icon {
        public enum ID {
          case unknown
          case energy
          
          init(_ size: _EnergyRewardReceipt._Item._ICON._IconID) {
            switch size {
            case .iconUnknown:    self = .unknown
            case .iconEnergy:     self = .energy
            case .UNRECOGNIZED:   self = .unknown
            }
          }
          
          var _id: _EnergyRewardReceipt._Item._ICON._IconID {
            switch self {
            case .unknown:        return .iconUnknown
            case .energy:         return .iconEnergy
            }
          }
        }
        
        public let id: ID
        
        public init(id: ID) {
          self.id = id
        }
      }
      
      case none
      case nft(NFT)
      case energy(Energy)
      case icon(Icon)
    }
    
    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _EnergyRewardReceipt._Item

    public init(itemId: String,
                name: String,
                description: String?,
                chance: Decimal,
                type: `Type`,
                payload: Payload,
                database: (any WalletDB)? = nil) {
      self.database = database ?? MEWwalletDBImpl.shared
      self._chain = .universal
      self._wrapped = .with {
        $0.itemID = itemId
        $0.name = name
        if let description {
          $0.description_p = description
        }
        $0.chance = chance.decimalString
        $0.type = type._item_type
        switch payload {
        case .nft(let nft):
          $0.payload = .nft(.with({
            $0.tokenID = Int64(nft.tokenId)
            $0.rarity = nft.rarity._rarity
            $0.url = nft.url.absoluteString
          }))
        case .energy(let energy):
          $0.payload = .energy(.with({
            $0.url = energy.url.absoluteString
            $0.size = energy.size._size
            $0.amount = energy.amount.decimalString
          }))
        case .icon(let icon):
          $0.payload = .icon(.with({
            $0.id = icon.id._id
          }))
        case .none:
          $0.payload = .none
        }
      }
    }
  }
}

// MARK: - EnergyRewardReceipt.Item + Properties

extension EnergyRewardReceipt.Item {
  
  // MARK: - Properties
  
  public var itemId: String { _wrapped.itemID }
  public var name: String { _wrapped.name }
  public var nameWithoutSuffixNFT: String {
    guard _wrapped.name.hasSuffix(" NFT"), _wrapped.name.count > 4 else { return _wrapped.name }
    return String(_wrapped.name.dropLast(4))
  }
  public var description: String? {
    guard _wrapped.hasDescription_p else { return nil }
    return _wrapped.description_p
  }
  public var chance: Decimal { Decimal(wrapped: _wrapped.chance, hex: false) ?? .zero }
  
  public var type: `Type` { .init(_wrapped.type) }
  
  public var payload: Payload {
    switch _wrapped.payload {
    case .nft(let nft):
      return .nft(.init(
        tokenId: Int(clamping: nft.tokenID),
        url: URL(string: nft.url)!,
        rarity: .init(nft.rarity)
      ))
    case .energy(let energy):
      return .energy(.init(
        url: URL(string: energy.url)!,
        amount: Decimal(wrapped: energy.amount, hex: false) ?? .zero,
        size: .init(energy.size)
      ))
    case .icon(let icon):
      return .icon(.init(
        id: .init(icon.id)
      ))
    case .none:
      return .none
    }
  }
  
  public var url: URL? {
    switch _wrapped.payload {
    case .nft(let nft):         return URL(string: nft.url)
    case .energy(let energy):   return URL(string: energy.url)
    default:                    return nil
    }
  }
}

// MARK: - _EnergyRewardReceipt._Item + ProtoWrappedMessage

extension _EnergyRewardReceipt._Item: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> EnergyRewardReceipt.Item {
    return EnergyRewardReceipt.Item(self, chain: .universal)
  }
}

// MARK: - EnergyRewardReceipt.Item + ProtoWrapper

extension EnergyRewardReceipt.Item: ProtoWrapper {
  init(_ wrapped: _EnergyRewardReceipt._Item, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
