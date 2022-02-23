import Foundation

public final class TokenResponseKey: MDBXKey {
  public var key: Data = Data()
  
  public var projectId: Data {
    return key[0...16]
  }
  
  public var id: String {
    let keyCount = key.count
    return key[16..<keyCount].hexString
  }
  
  public init(projectId: MDBXProjectId, id: String) {
    self.key = (projectId.rawValue.setLengthLeft(16) + Data(hex: id))
  }
  
  init(rawWithdrawResponseKey: Data) {
    self.key = rawWithdrawResponseKey
  }
  
}
