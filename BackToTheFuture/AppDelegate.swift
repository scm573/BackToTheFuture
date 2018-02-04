//
//  AppDelegate.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/01/26.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static let shared = UIApplication.shared.delegate as! AppDelegate
    let stack = CoreDataStack(modelName: "Model")!
}

