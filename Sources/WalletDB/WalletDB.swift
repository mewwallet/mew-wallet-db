//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/19/21.
//

import Foundation
import mdbx_ios

public protocol WalletDB: AnyObject, DBLifecycle, DBRead, DBWrite, DBTable, DBDelete { }
