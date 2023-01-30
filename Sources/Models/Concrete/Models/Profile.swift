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
    case badData
    
    public var errorDescription: String? {
      switch self {
      case .alreadyExist:     return "Update error: Already exist"
      case .platformNotSet:   return "Update error: Platform not set"
      case .nothingToUpdate:  return "Update error: Nothing to update"
      case .notFound:         return "Update error: Not found"
      case .badData:          return "Update error: Bad data"
      }
    }
  }
  
  public enum Error: LocalizedError {
    case noStatus
    
    public var errorDescription: String? {
      switch self {
      case .noStatus:         return "Profile error: no status"
      }
    }
  }
  
  public struct AddressFlags: OptionSet {
    public let rawValue: UInt32
    
    /// Option represent all disabled flags
    /// mask `0b0000_0000`
    public static let disabled                            = AddressFlags(rawValue: UInt32(_Profile._Settings._Address._AddressFlags.disabled.rawValue))
    
    /// Option to include specific address to portfolio weekly tracker
    /// mask: `0b0000_0001`
    public static let includeInWeeklyPortfolio            = AddressFlags(rawValue: UInt32(_Profile._Settings._Address._AddressFlags.includeInWeeklyPortfolioTracker.rawValue))
    
    /// Option to include specific address to portfolio daily tracker
    /// mask: `0b0000_0010`
    public static let includeInDailyPortfolio             = AddressFlags(rawValue: UInt32(_Profile._Settings._Address._AddressFlags.includeInDailyPortfolioTracker.rawValue))
    
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
  
  public struct NotificationFlags: OptionSet {
    public let rawValue: UInt32
    
    /// Option represent all disabled flags
    /// mask `0b0000_0000`
    public static let disabled                            = NotificationFlags(rawValue: UInt32(_Profile._Settings._Notifications.disabled.rawValue))
    
    /// Option to enable/disable outgoing notifications
    /// mask: `0b0000_0001`
    public static let outgoingTx                          = NotificationFlags(rawValue: UInt32(_Profile._Settings._Notifications.outgoingTx.rawValue))
    /// Option to enable/disable incoming notifications
    /// mask: `0b0000_0010`
    public static let incomingTx                          = NotificationFlags(rawValue: UInt32(_Profile._Settings._Notifications.incomingTx.rawValue))
    /// Option to enable/disable announcements notifications
    /// mask: `0b0000_0100`
    public static let announcements                       = NotificationFlags(rawValue: UInt32(_Profile._Settings._Notifications.announcements.rawValue))
    /// Option to enable/disable security notifications
    /// mask: `0b0000_1000`
    public static let security                            = NotificationFlags(rawValue: UInt32(_Profile._Settings._Notifications.security.rawValue))
    
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
  @SubProperty<_Profile._Settings._PortfolioTracker._TrackerTime, Profile.TrackerTime> var _dailyPortfolioTracker: _Profile._Settings._PortfolioTracker._TrackerTime?
  @SubProperty<_Profile._Settings._PortfolioTracker._TrackerTime, Profile.TrackerTime> var _weeklyPortfolioTracker: _Profile._Settings._PortfolioTracker._TrackerTime?
  @SubProperty<_Profile._Status, Profile.Status> var _status: _Profile._Status?
  
  // MARK: - Lifecycle
  
  public init() {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .universal
    self._wrapped = .with {
      $0.settings = .with {
        $0.addresses = []
        $0.timezone = ""
        $0.portfolioTracker = .with {
          $0.daily = .with {
            var preComponents = DateComponents()
            preComponents.hour = 8
            preComponents.minute = 0
            let (components, formatter) = preComponents.trackerTime(includeDay: false)
            if let date = components.date {
              $0.timestamp = formatter.string(from: date)
            } else {
              $0.timestamp = "08:00+00:00"
            }
            
            $0.enabled = true
          }
          $0.weekly = .with {
            var preComponents = DateComponents()
            preComponents.hour = 8
            preComponents.minute = 0
            preComponents.day = 1
            let (components, formatter) = preComponents.trackerTime(includeDay: true)
            if let date = components.date {
              $0.timestamp = formatter.string(from: date)
            } else {
              $0.timestamp = "1T08:00+00:00"
            }
            
            $0.enabled = true
          }
        }
        /*
         Not in use yet,
         ~Foboz
         
        $0.priceAlerts = [
          .with {
            $0.contractAddress = Address.primary.rawValue
            $0.trigger = "LARGE_MOVE"
            $0.type = "DISABLED"
          }
        ]
         */
        $0.gmtOffset = 0
        $0.pushToken = ""
        $0.platform = ""
        $0.notifications = NotificationFlags.all.rawValue
      }
      $0.status = .with {
        $0.status = Profile.Status.Status.inactive.rawValue
        $0.lastUpdate = .init()
        $0.checksum = ($0.lastUpdate.textFormatString() + $0.status).sha256.hexString
      }
    }
    self.commonInit(chain: .universal)
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
  mutating public func set(platform: Platform, force: Bool) throws -> Patch {
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.platform
    
    if !force {
      guard self._wrapped.settings.platform != platform.rawValue else { throw UpdateError.nothingToUpdate }
    }
    
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
    
    // Refresh wrapper with new wrapped value
    __dailyPortfolioTracker.refreshProjected(wrapped: _wrapped.settings.portfolioTracker.daily)
    $_dailyPortfolioTracker?._type = .daily
    precondition(self.$_dailyPortfolioTracker?._type == .daily)
    
    return .replace(path: keypath.stringValue, value: dailyPortfolioTracker)
  }
  
  /// Prepares `PATCH` data to set daily portfolio tracker time
  /// - Parameter dailyPortfolioTracker: time (weekday and time)
  /// - Returns: `PATCH` data
  mutating public func set(dailyPortfolioTracker: DateComponents, force: Bool = false) throws -> Patch {
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    guard dailyPortfolioTracker.hour != nil, dailyPortfolioTracker.minute != nil else { throw UpdateError.badData }
    
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.portfolioTracker.daily.timestamp
    
    let (components, formatter) = dailyPortfolioTracker.trackerTime(includeDay: false)
    guard let date = components.date else { throw UpdateError.badData }
    let time = formatter.string(from: date)
    
    if !force {
      guard self._wrapped.settings.portfolioTracker.daily.timestamp != time else { throw UpdateError.nothingToUpdate }
    }
    
    self._wrapped.settings.portfolioTracker.daily.timestamp = time
    
    // Refresh wrapper with new wrapped value
    __dailyPortfolioTracker.refreshProjected(wrapped: _wrapped.settings.portfolioTracker.daily)
    $_dailyPortfolioTracker?._type = .daily
    precondition(self.$_dailyPortfolioTracker?._type == .daily)
    
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
    
    // Refresh wrapper with new wrapped value
    __weeklyPortfolioTracker.refreshProjected(wrapped: _wrapped.settings.portfolioTracker.weekly)
    $_weeklyPortfolioTracker?._type = .weekly
    precondition(self.$_weeklyPortfolioTracker?._type == .weekly)
    
    return .replace(path: keypath.stringValue, value: weeklyPortfolioTracker)
  }
  
  /// Prepares `PATCH` data to set weekly portfolio tracker time
  /// - Parameter dailyPortfolioTracker: time (time)
  /// - Returns: `PATCH` data
  mutating public func set(weeklyPortfolioTracker: DateComponents, force: Bool = false) throws -> Patch {
    precondition((weeklyPortfolioTracker.day ?? 0) >= 1)
    precondition((weeklyPortfolioTracker.day ?? 0) <= 7)
    guard self.platform != .empty else { throw UpdateError.platformNotSet }
    guard weeklyPortfolioTracker.hour != nil, weeklyPortfolioTracker.minute != nil else { throw UpdateError.badData }
    
    let keypath: KeyPath<_Profile, String> = \_Profile.settings.portfolioTracker.weekly.timestamp
    
    let (components, formatter) = weeklyPortfolioTracker.trackerTime(includeDay: true)
    guard let date = components.date else { throw UpdateError.badData }
    let time = formatter.string(from: date)
    
    if !force {
      guard self._wrapped.settings.portfolioTracker.weekly.timestamp != time else { throw UpdateError.nothingToUpdate }
    }
    
    self._wrapped.settings.portfolioTracker.weekly.timestamp = time
    
    // Refresh wrapper with new wrapped value
    __weeklyPortfolioTracker.refreshProjected(wrapped: _wrapped.settings.portfolioTracker.weekly)
    $_weeklyPortfolioTracker?._type = .weekly
    precondition(self.$_weeklyPortfolioTracker?._type == .weekly)
    
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
  
  public var dailyTracker: Profile.TrackerTime {
    guard let tracker = self.$_dailyPortfolioTracker else {
      var tracker = Profile.TrackerTime(_wrapped.settings.portfolioTracker.daily, chain: .universal)
      tracker._type = .daily
      return tracker
    }
    precondition(tracker._type == .daily)
    return tracker
  }
  
  public var weeklyTracker: Profile.TrackerTime {
    guard let tracker = self.$_weeklyPortfolioTracker else {
      var tracker = Profile.TrackerTime(_wrapped.settings.portfolioTracker.weekly, chain: .universal)
      tracker._type = .weekly
      return tracker
    }
    precondition(tracker._type == .weekly)
    return tracker
  }
  
  public var addresses: [Address] { _wrapped.settings.addresses.map({ Address($0.address) }) }
  public var notificationsFlags: NotificationFlags { NotificationFlags(rawValue: _wrapped.settings.notifications) }
  public var pushToken: String { _wrapped.settings.pushToken }
  public var status: Profile.Status {
    get throws {
      guard let status = self.$_status else { throw Error.noStatus }
      return status
    }
  }
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
    self._chain = .universal
    self._wrapped = try _Profile(serializedData: data)
    self.commonInit(chain: .universal)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _Profile(jsonUTF8Data: jsonData, options: options)
    self.commonInit(chain: .universal)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _Profile(jsonString: jsonString, options: options)
    self.commonInit(chain: .universal)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Profile.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Profile.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! Profile
    
    self._wrapped.settings = other._wrapped.settings
    self._wrapped.status = other._wrapped.status
  }
}

// MARK: - _Profile + ProtoWrappedMessage

extension _Profile: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Profile {
    var profile = Profile(self, chain: chain)
    profile.commonInit(chain: .universal)
    return profile
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
    self._chain = .universal
    self._wrapped = wrapped
    self.commonInit(chain: .universal)
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

// MARK: - Profile + CommonInit

extension Profile {
  mutating func commonInit(chain: MDBXChain) {
    // Wrappers
    __dailyPortfolioTracker.chain = .universal
    __dailyPortfolioTracker.wrappedValue = _wrapped.settings.portfolioTracker.daily
    __dailyPortfolioTracker.projectedValue?._type = .daily
    
    __weeklyPortfolioTracker.chain = .universal
    __weeklyPortfolioTracker.wrappedValue = _wrapped.settings.portfolioTracker.weekly
    __weeklyPortfolioTracker.projectedValue?._type = .weekly
    
    __status.chain = .universal
    __status.wrappedValue = _wrapped.status
    
    self.populateDB()
  }
  
  func populateDB() {
    __dailyPortfolioTracker.database = database
    __weeklyPortfolioTracker.database = database
    __status.database = database
  }
}
