//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/15/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios
import mew_wallet_ios_extensions

public struct Profile {
  public enum Patch {
    case remove(path: String)
    case add(path: String, value: Encodable)
    case replace(path: String, value: Encodable)
  }
  
  public enum UpdateError: LocalizedError {
    case alreadyExist
    case platformNotSet
    case nothingToUpdate
    case notFound
    
    public var errorDescription: String? {
      switch self {
      case .alreadyExist:     return "Update error: Already exist"
      case .platformNotSet:   return "Update error: Platform not set"
      case .nothingToUpdate:  return "Update error: Nothing to update"
      case .notFound:         return "Update error: Not found"
      }
    }
  }
  
  public struct AddressFlags: OptionSet {
    public let rawValue: UInt32
    
    /// Option to include specific address to portfolio weekly tracker
    /// mask: 0b00000001
    public static let includeInWeeklyPortfolio            = AddressFlags(rawValue: 1 << 0)
    /// Option to include specific address to portfolio daily tracker
    /// mask: 0b00000010
    public static let includeInDailyPortfolio             = AddressFlags(rawValue: 1 << 1)
    
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
  
  public struct NotificationFlags: OptionSet {
    public let rawValue: UInt32
    
    /// Option to enable/disable outgoing notifications
    /// mask: 0b00000001
    public static let outgoingTx                          = NotificationFlags(rawValue: 1 << 0)
    /// Option to enable/disable incoming notifications
    /// mask: 0b00000010
    public static let incomingTx                          = NotificationFlags(rawValue: 1 << 1)
    /// Option to enable/disable announcements notifications
    /// mask: 0b00000100
    public static let announcements                       = NotificationFlags(rawValue: 1 << 2)
    /// Option to enable/disable security notifications
    /// mask: 0b00001000
    public static let security                            = NotificationFlags(rawValue: 1 << 3)
    
    public static let all: NotificationFlags              = [.outgoingTx, .incomingTx, .announcements, .security]
    
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
  
  public enum Platform: String {
    case empty      = ""
    case iOS        = "IOS"
    case Android    = "ANDROID"
  }
  
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _Profile
  var _chain: MDBXChain
  
  // MARK: - Lifecycle
  
  public init() {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .eth
    self._wrapped = .with {
      $0.settings = .with {
        $0.addresses = []
        $0.timezone = ""
        $0.portfolioTracker = .with {
          $0.daily = .with {
            $0.enabled = true
            $0.timestamp = "1T9:00+00:00"
          }
          $0.weekly = .with {
            $0.enabled = true
            $0.timestamp = "9:00+00:00"
          }
        }
        $0.priceAlerts = [
          .with {
            $0.contractAddress = Address.primary.rawValue
            $0.trigger = "LARGE_MOVE"
            $0.type = "DISABLED"
          }
        ]
        $0.gmtOffset = 0
        $0.pushToken = ""
        $0.platform = ""
        $0.notifications = NotificationFlags.all.rawValue
      }
    }
  }
}

// MARK: - Profile + Properties

extension Profile {
  
  // MARK: - Patch
  
  /// Prepares `PATCH` data to update notification settings
  /// - Parameters:
  ///   - notificationFlag: notification flag to add/remove
  ///   - enable: add/remove
  /// - Returns: `PATCH` data
  mutating public func set(notificationFlag: NotificationFlags, enable: Bool) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    let keypath: KeyPath<_Profile, UInt32> = \_Profile.settings.notifications

    var settings = NotificationFlags(rawValue: self._wrapped.settings.notifications)
    if enable {
      settings = settings.union(notificationFlag)
    } else {
      settings = settings.subtracting(notificationFlag)
    }
    
    guard _wrapped.settings.notifications != settings.rawValue else { throw UpdateError.nothingToUpdate }
    
    _wrapped.settings.notifications = settings.rawValue
    
    return .replace(path: keypath.stringValue, value: settings.rawValue)
  }
  
  /// Prepares `PATCH` data to update timezone
  /// - Returns: `PATCH` data
  mutating public func setTimeZone() throws -> [Patch] {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    let timezone = TimeZone.current
    
    var patches: [Patch] = []
    if _wrapped.settings.timezone != timezone.identifier {
      let keypath: KeyPath<_Profile, String> = \_Profile.settings.timezone
      patches.append(.replace(path: keypath.stringValue, value: timezone.identifier))
      self._wrapped.settings.timezone = timezone.identifier
    }
    if _wrapped.settings.gmtOffset != Int64(timezone.secondsFromGMT()) {
      let keypath: KeyPath<_Profile, Int64> = \_Profile.settings.gmtOffset
      patches.append(.replace(path: keypath.stringValue, value: timezone.secondsFromGMT()))
      self._wrapped.settings.gmtOffset = Int64(timezone.secondsFromGMT())
    }
    
    guard !patches.isEmpty else { throw UpdateError.nothingToUpdate }
    
    return patches
  }
  
  /// Prepares `PATCH` data to update platform
  /// - Parameter platform: platform to be set
  /// - Returns: `PATCH` data
  mutating public func set(platform: Platform) throws -> Patch {
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.platform
    
    guard self._wrapped.settings.platform != platform.rawValue else { throw UpdateError.nothingToUpdate }
    
    self._wrapped.settings.platform = platform.rawValue
    
    return .replace(path: keypath.stringValue, value: platform.rawValue)
  }
  
  /// Prepare `PATCH` data to add new address. Throws an error if address already exist
  /// - Parameters:
  ///   - address: address to add
  ///   - flags: flags for that address
  /// - Returns: `PATCH` data
  mutating public func add(address: Address, flags: AddressFlags = [.includeInDailyPortfolio, .includeInWeeklyPortfolio]) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    guard !_wrapped.settings.addresses.contains(where: { Address($0.address) == address }) else { throw UpdateError.alreadyExist }
    
    let keypath: KeyPath<_Profile, _Profile._Settings._Address?> = \_Profile.settings.addresses.last
    
    var account = _Profile._Settings._Address()
    account.address = address.rawValue
    account.flags = flags.rawValue
    
    _wrapped.settings.addresses.append(account)
    
    return .add(path: keypath.stringValue, value: account)
  }
  
  mutating public func remove(address: Address) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    guard let index = _wrapped.settings.addresses.firstIndex(where: { Address($0.address) == address }) else { throw UpdateError.notFound }
    
    let keypath: KeyPath<_Profile, _Profile._Settings._Address?> = \_Profile.settings.addresses.first
    
    _wrapped.settings.addresses.remove(at: index)
    
    return .remove(path: keypath.stringValue(index))
  }
  
  /// Prepares `PATCH` data to enable/disable daily portfolio tracker
  /// - Parameter dailyPortfolioTracker: enable/disable
  /// - Returns: `PATCH` data
  mutating public func enable(dailyPortfolioTracker: Bool) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    guard self._wrapped.settings.portfolioTracker.daily.enabled != dailyPortfolioTracker else { throw UpdateError.nothingToUpdate }
    
    let keypath: KeyPath<_Profile, Bool> = \_Profile.settings.portfolioTracker.daily.enabled
    
    self._wrapped.settings.portfolioTracker.daily.enabled = dailyPortfolioTracker
    
    return .replace(path: keypath.stringValue, value: dailyPortfolioTracker)
  }
  
  /// Prepares `PATCH` data to set daily portfolio tracker time
  /// - Parameter dailyPortfolioTracker: time (weekday and time)
  /// - Returns: `PATCH` data
  mutating public func set(dailyPortfolioTracker: Date) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.portfolioTracker.daily.timestamp
    
    let locale = Locale(identifier: "en_US_POSIX")
    var calendar = Calendar(identifier: .iso8601)

    calendar.timeZone = .current
    calendar.locale = locale

    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = calendar
    formatter.timeZone = .current
    formatter.dateFormat = "e'T'HH:mmZ"

    let time = formatter.string(from: dailyPortfolioTracker)
    
    guard self._wrapped.settings.portfolioTracker.daily.timestamp != time else { throw UpdateError.nothingToUpdate }
    
    self._wrapped.settings.portfolioTracker.daily.timestamp = time
    
    return .replace(path: keypath.stringValue, value: time)
  }
  
  /// Prepares `PATCH` data to enable/disable daily portfolio tracker
  /// - Parameter weeklyPortfolioTracker: enable/disable
  /// - Returns: `PATCH` data
  mutating public func enable(weeklyPortfolioTracker: Bool) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    guard self._wrapped.settings.portfolioTracker.weekly.enabled != weeklyPortfolioTracker else { throw UpdateError.nothingToUpdate }
    
    let keypath: KeyPath<_Profile, Bool> = \_Profile.settings.portfolioTracker.weekly.enabled
    
    self._wrapped.settings.portfolioTracker.weekly.enabled = weeklyPortfolioTracker
    
    return .replace(path: keypath.stringValue, value: weeklyPortfolioTracker)
  }
  
  /// Prepares `PATCH` data to set weekly portfolio tracker time
  /// - Parameter dailyPortfolioTracker: time (time)
  /// - Returns: `PATCH` data
  mutating public func set(weeklyPortfolioTracker: Date) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.portfolioTracker.weekly.timestamp
    
    let locale = Locale(identifier: "en_US_POSIX")
    var calendar = Calendar(identifier: .iso8601)

    calendar.timeZone = .current
    calendar.locale = locale

    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = calendar
    formatter.timeZone = .current
    formatter.dateFormat = "HH:mmZ"

    let time = formatter.string(from: weeklyPortfolioTracker)
    
    guard self._wrapped.settings.portfolioTracker.weekly.timestamp != time else { throw UpdateError.nothingToUpdate }
    
    self._wrapped.settings.portfolioTracker.weekly.timestamp = time
    
    return .replace(path: keypath.stringValue, value: time)
  }
  
  /// Prepares `PATCH` data to set pushToken
  /// - Parameter pushToken: push token
  /// - Returns: `PATCH` data
  mutating public func set(pushToken: String) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.pushToken
    
    guard self._wrapped.settings.pushToken != pushToken else { throw UpdateError.nothingToUpdate }
    
    self._wrapped.settings.pushToken = pushToken
    
    return .replace(path: keypath.stringValue, value: pushToken)
  }
  
  /// Prepares `PATCH` data to set specific flag for address
  /// - Parameters:
  ///   - flag: flag to be set/remove
  ///   - address: address
  ///   - enable: set/remove
  /// - Returns: `PATCH` data
  mutating public func set(flag: AddressFlags, for address: Address, enable: Bool) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    
    guard let index = _wrapped.settings.addresses.firstIndex(where: { Address(rawValue: $0.address) == address }) else { throw UpdateError.notFound }
    
    var account = _wrapped.settings.addresses[index]
    
    var flags = AddressFlags(rawValue: account.flags)
    if enable {
      flags = flags.union(flag)
    } else {
      flags = flags.subtracting(flag)
    }
    
    guard account.flags != flags.rawValue else { throw UpdateError.nothingToUpdate }
    
    let keypath: KeyPath<_Profile, UInt32?> = \_Profile.settings.addresses.last?.flags
    
    account.flags = flags.rawValue
    _wrapped.settings.addresses[index] = account
    
    return .replace(path: keypath.stringValue(index), value: flags.rawValue)
  }
  
  // MARK: - Properties
  
  public var platform: Platform { return Platform(rawValue: _wrapped.settings.platform) ?? .empty }
  
}

// MARK: - Profile + MDBXObject

extension Profile: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    fatalError("Not in use")
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Profile(serializedData: data)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Profile(jsonUTF8Data: jsonData, options: options)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Profile(jsonString: jsonString, options: options)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Profile.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Profile.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! Profile
    
    self._wrapped.settings = other._wrapped.settings
  }
}

// MARK: - _Profile + ProtoWrappedMessage

extension _Profile: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Profile {
    return Profile(self, chain: chain)
  }
}

// MARK: - Profile + Equitable

extension Profile: Equatable {
  public static func ==(lhs: Profile, rhs: Profile) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Profile + ProtoWrapper

extension Profile: ProtoWrapper {
  init(_ wrapped: _Profile, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - Profile + Hashable

extension Profile: Hashable {
  public func hash(into hasher: inout Hasher) {
    _wrapped.hash(into: &hasher)
  }
}

// MARK: - Profile + Sendable

extension Profile: Sendable {}

// MARK: - KeyPath<_Profile, _> + String value

private extension PartialKeyPath where Root == _Profile {
  var stringValue: String {
    switch self {
    case \_Profile.settings.notifications:                      return "/settings/notifications"
    case \_Profile.settings.timezone:                           return "/settings/timezone"
    case \_Profile.settings.gmtOffset:                          return "/settings/gmt_offset"
    case \_Profile.settings.addresses.last:                     return "/settings/addresses/-"
    case \_Profile.settings.platform:                           return "/settings/platform"
    case \_Profile.settings.portfolioTracker.daily.enabled:     return "/settings/portfolio_tracker/daily/enabled"
    case \_Profile.settings.portfolioTracker.daily.timestamp:   return "/settings/portfolio_tracker/daily/timestamp"
    case \_Profile.settings.portfolioTracker.weekly.enabled:    return "/settings/portfolio_tracker/weekly/enabled"
    case \_Profile.settings.portfolioTracker.weekly.timestamp:  return "/settings/portfolio_tracker/weekly/timestamp"
    case \_Profile.settings.pushToken:                          return "/settings/push_token"
      
    default: fatalError("Unexpected key path")
    }
  }
  
  func stringValue(_ index: Int) -> String {
    switch self {
    case \_Profile.settings.addresses.first:                    return "/settings/addresses/\(index)"
    case \_Profile.settings.addresses.last?.flags:              return "/settings/addresses/\(index)/flags"
    default:
      return stringValue
    }
  }
}

// MARK: - _Profile._Settings._Address + Encodable

extension _Profile._Settings._Address: Encodable {
  private enum CodingKeys: CodingKey {
    case address
    case flags
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(self.address, forKey: .address)
    try container.encode(self.flags, forKey: .flags)
  }
}
