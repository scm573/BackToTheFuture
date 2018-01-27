//
//  GCDBlackBox.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/27.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import Foundation

internal func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
