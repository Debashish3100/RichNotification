//
//  ViewController.swift
//  RichNotification
//
//  Created by Debashish Das on 9/29/20.
//  Copyright © 2020 Debashish Das. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK: - Property
    
    //let manager = CoreDataManager(modelName: "RichNotification")
    let manager = CoreDataStack(moduleName: "RichNotification")
    
    //MARK: - Outlet
    
    @IBOutlet weak var onClickButton: UIButton!
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: Notification.Name.didReceiveNotification, object: nil)
    }
    
    //MARK: - Deinitializer
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    
    @IBAction func onClick(_ sender: UIButton) {
        fetchMessages()
        fetchUserDefaultsData()
    }
    
    @objc private func notificationReceived(_ : Notification) {
        print("notification received")
        fetchMessages()
        fetchUserDefaultsData()
    }
    
    //MARK: - fetchUserDefaultsData
    
    private func fetchUserDefaultsData() {
        if let defaults = UserDefaults(suiteName: "group.com.eikyoo.notificationrich") {
            if let value = defaults.value(forKey: "notification") as? String {
                print("value is : \(value)")
            } else {
                print("no value")
            }
        } else {
            print("no user defaults")
        }
    }
    
    //MARK: - FetchMessages
    
    private func fetchMessages() {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
//        manager.mainManagedObjectContext.performAndWait {
//            do {
//                let msgs = try fetchRequest.execute()
//                for eachMsg in msgs {
//                    print(eachMsg.title ?? "NO title")
//                    print(eachMsg.body ?? "NO body")
//                }
//                if msgs.isEmpty {
//                    print("no data")
//                }
//            } catch {
//                print("error in fetching messages")
//                print(error.localizedDescription)
//            }
//        }
        manager.context.performAndWait {
            do {
                let msgs = try fetchRequest.execute()
                for eachMsg in msgs {
                    print(eachMsg.title ?? "NO title")
                    print(eachMsg.body ?? "NO body")
                }
                if msgs.isEmpty {
                    print("no data")
                }
            } catch {
                print("error in fetching messages")
                print(error.localizedDescription)
            }
        }
    }
}
