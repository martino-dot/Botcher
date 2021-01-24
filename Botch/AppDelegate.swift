//
//  AppDelegate.swift
//  Botch
//
//  Created by Martin Velev on 7/2/20.
//

import UIKit
import CoreData
import Valet
import SwiftyStoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let myValet = Valet.valet(with: Identifier(nonEmpty: "Purchased")!, accessibility: .whenUnlocked)
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "Botcher")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        try? self.myValet.setString("true", forKey: "Purchased")
                    case .failed, .purchasing, .deferred:
                        try? self.myValet.setString("false", forKey: "Purchased")
                    @unknown default:
                        try? self.myValet.setString("false", forKey: "Purchased")
                    }
                }
            }
        return true
    }
    
    static var persistentContainer: NSPersistentContainer {return (UIApplication.shared.delegate as! AppDelegate).persistentContainer}
    static var viewContext: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
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
    func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
    }
    // MARK: - Core Data stack
    // MARK: - Core Data Saving support
    func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
    do {
    try context.save()
    } catch {
    // Replace this implementation with code to handle the error appropriately.
    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    let nserror = error as NSError
    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
    }
    }

}
