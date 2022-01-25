//
//  AppDelegate.swift
//  Task
//
//  Created by Arunkumar on 23/01/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var fileData : Data?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let v = UserDefaults.standard.object(forKey: "data") {
            print("v \(v)")
        } else {
            print("No Data")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    var backgroundCompletionHandler : ( () -> Void )?
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        coder.encode(self.fileData,forKey: "data")
        return true
    }
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        coder.encode(self.fileData,forKey: "data")
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
       
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        self.fileData = coder.decodeObject(forKey: "data") as? Data
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
//        UserDefaults.standard.set(self.fileData, forKey: "data")
//        UserDefaults.standard.synchronize()
    }
    
//    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
//        UIApplication.shared.extendStateRestoration()
//        DispatchQueue.main.async {
//            UIApplication.shared.completeStateRestoration()
//        }
//    }


}

