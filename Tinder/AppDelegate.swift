//
//  AppDelegate.swift
//  Tinder
//
//  Created by Avaz Abdrasulov on 9/10/18.
//  Copyright © 2018 Avaz Abdrasulov. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import UserNotifications
import ObjectMapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var appIsStarting = false
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let options = launchOptions, options[UIApplicationLaunchOptionsKey.remoteNotification] != nil{
            self.appIsStarting = true
        }
        
        registerForPushNotifications()
        configureFirebase()
        customizeNavigationBar()
        customizeTabbar()
        IQKeyboardManager.shared.enable = true
        
        APNsManager.instance.setupTokens()
        
        return true
    }
    
    func configureFirebase(){
        FirebaseApp.configure()
        
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func customizeNavigationBar(){
        UINavigationBar.appearance().tintColor = UIColor(hex:0x25324C)
        UINavigationBar.appearance().alpha = 1.0
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().backIndicatorTransitionMaskImage
            = UIImage(named: "ic_nav_back_button")
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "ic_nav_back_button")
    }
    
    func customizeTabbar(){
        UITabBar.appearance().tintColor = UIColor(hex:0x25324C)
    }
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        APNsManager.instance.setupTokens()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Push: \(userInfo)")
        
        let state = application.applicationState

        if state == .inactive && self.appIsStarting{
            
            guard Auth.auth().currentUser != nil else{
                return
            }
            
            if let notification = Mapper<PushNotification>().map(JSON: userInfo as! [String: Any]){
                if notification.notificationType == PushNotificationType.NewMessage.rawValue{
                    if let vc = self.window!.rootViewController{
                        if vc.view != nil{
                            vc.openChat(chatId: notification.chatId)
                        }
                    }
                }
            }
            
            completionHandler(UIBackgroundFetchResult.newData)
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func clearNotifications(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.appIsStarting = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.appIsStarting = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.appIsStarting = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        clearNotifications(application)
        self.appIsStarting = false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

