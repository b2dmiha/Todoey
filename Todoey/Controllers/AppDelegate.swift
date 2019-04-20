//
//  AppDelegate.swift
//  Todoey
//
//  Created by Michael Gimara on 08/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables
    var window: UIWindow?

    // MARK: - Application Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            _ = try Realm()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        //print(Realm.Configuration.defaultConfiguration.fileURL!)

        return true
    }
}

