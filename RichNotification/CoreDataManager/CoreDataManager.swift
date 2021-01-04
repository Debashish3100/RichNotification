//
//  CoreDataManager.swift
//  RichNotification
//
//  Created by Debashish Das on 28/12/20.
//  Copyright © 2020 Debashish Das. All rights reserved.
//

// CHILD - PARENT ARRANGEMENT :

// 1. child managedObject Context - > .mainQueueConcurrencyType >> (User will interact with child) <<
// 2. parent managedObject Context - > .privateQueueConcurrencyType

import CoreData
import UIKit

extension Notification.Name {
    static let didReceiveNotification = Notification.Name(rawValue: "com.RichNotification.DidReceiveNotification")
}

final class CoreDataManager {
    private let modelName: String
    
    //MARK: - Initializer
    
    init(modelName: String) {
        self.modelName = modelName
        setupNotificationHandling()
    }
    
    //MARK: - ManagedObjectContext
    
    //MARK: Parent ManagedObjectContext
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistantStoreCoordinator
        return context
    }()
    
    //MARK: Child ManagedObjectContext
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.privateManagedObjectContext
        return context
    }()
    
    //MARK: - ManagedObjectModel
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let dataModelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { fatalError("unable to find data model url") }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelUrl) else { fatalError("unable to find data model") }
        return dataModel
    }()
    
    //MARK: - PersistantStoreCoordinator
    
    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.debashish.notificationrich")!
        let storeUrl =  directory.appendingPathComponent(storeName)
        do {
            //MARK: for LightWeight Migration
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true,
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        } catch {
            fatalError("unable to add store")
        }
        return coordinator
    }()
    
    //MARK: - Save
    
    func saveChanges() {
        mainManagedObjectContext.perform {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                print("saving error : child : - \(error.localizedDescription)")
            }
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                print("saving error : parent : - \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Helper Methods
    
    @objc func saveChanges(notificaiton: Notification) {
        saveChanges()
    }
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name:  UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}

//MARK: - DarwinNotificationCenter Implementation

//extension CoreDataManager {
//    // Configure change event handling from external processes.
//    func observeAppExtensionDataChanges() {
//        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
//            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
//            self?.mainManagedObjectContext.perform {
//                self?.viewContextDidSaveExternally()
//            }
//        })
//    }
//}
//extension CoreDataManager {
//
//    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
//    func viewContextDidSaveExternally() {
//        print("saved")
//        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
//        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
//        mainManagedObjectContext.stalenessInterval = 0
//        mainManagedObjectContext.refreshAllObjects()
//        mainManagedObjectContext.stalenessInterval = -1
//    }
//}
