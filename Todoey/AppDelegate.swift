//
//  AppDelegate.swift
//  Destini

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        do{
            _ = try Realm()
        }catch{
            print("Realm Error: \(error)")
        }
        
        
        return true
    }
}

