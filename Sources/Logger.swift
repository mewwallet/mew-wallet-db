//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import OSLog

#if DEBUG
internal let lifecycleLogger = OSLog(subsystem: "com.myetherwallet.mewwalletdb", category: "mewwalletdb.lifecycle")
internal let tableLogger = OSLog(subsystem: "com.myetherwallet.mewwalletdb", category: "mewwalletdb.table")
internal let writeLogger = OSLog(subsystem: "com.myetherwallet.mewwalletdb", category: "mewwalletdb.write")
internal let readLogger = OSLog(subsystem: "com.myetherwallet.mewwalletdb", category: "mewwalletdb.read")
#else
internal let lifecycleLogger = OSLog.disabled
internal let tableLogger = OSLog.disabled
internal let writeLogger = OSLog.disabled
internal let readLogger = OSLog.disabled
#endif
