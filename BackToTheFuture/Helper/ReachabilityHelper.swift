//
//  ReachabilityHelper.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/27.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import Reachability

class ReachabilityHelper {
    static func isNetworkConnected() -> Bool {
        let conn = Reachability()?.connection
        switch conn {
        case .none:
            return false
        default:
            return true
        }
    }
}
