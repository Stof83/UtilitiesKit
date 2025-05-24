//
//  AppDelegate.swift
//  Example
//
//  Created by El Mostafa El Ouatri on 07/08/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let viewController = ViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: viewController)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

}

