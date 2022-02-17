
import Foundation
import SwiftProtobuf
import mdbx_ios
import OSLog

class ProtobufHelper {
    
    static func parse(data: Data) {
        
        do {
            let withdraw = try WithdrawResponse(jsonUTF8Data: data)
            print("minimum_deposit: \(withdraw.minimumDeposit)")
        } catch {
            print(error.localizedDescription)
        }
        
        //
        //        //TODO Sergey Kolokolnikov
        //        print("\(inputData.httpMethod!.uppercased()): \(inputData.url!.absoluteString)")
        //        if inputData.url!.absoluteString.contains("v2/swap/btc/ren/withdraw/fees") {
        //
        //            var inputData = inputData
        //            inputData.setValue("application/protobuf", forHTTPHeaderField: "Content-Type")
        //            inputData.setValue("application/protobuf", forHTTPHeaderField: "Accept")
        //
        //            self.networkClient.send(request: inputData, subscription: self.subscription) {[weak self] result in
        //              guard let strongSelf = self else { return }
        //
        //                switch result {
        //                case .success(let outputData):
        //                    if let data = outputData.data as? Data {
        //                        print(String(data: data, encoding: .utf8)  ?? "")
        //                        do {
        //                            //let withdraw = try WithdrawResponse(serializedData: data)
        //                            let withdraw = try WithdrawResponse(jsonUTF8Data: data)
        //                            print("minimum_deposit: \(withdraw.minimumDeposit)")
        //                        } catch {
        //                            print(error.localizedDescription)
        //                        }
        //                    }
        //                case .failure(let error):
        //                    print(error.localizedDescription)
        //                }
        //              strongSelf.completeOperation(result)
        //            }
        //
        //        } else {
        //            self.networkClient.send(request: inputData, subscription: self.subscription) {[weak self] result in
        //              guard let strongSelf = self else { return }
        //              strongSelf.completeOperation(result)
        //            }
        //        }
        
    }
    
}
