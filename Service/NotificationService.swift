//
//  NotificationService.swift
//  Service
//
//  Created by Debashish Das on 29/09/20.
//  Copyright © 2020 Debashish Das. All rights reserved.
//

import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let coreDataManager = CoreDataManager(modelName: "RichNotification")
    //let coreDataManager = CoreDataStack(moduleName: "RichNotification")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            //MARK: Save to UserDefaults
            
            if let defaults = UserDefaults(suiteName: "group.com.eikyoo.notificationrich") {
                if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                    if let data = self.getNotification(userInfo: aps) {
                        defaults.set("TITLE : \(data.0) + BODY : \(data.1)", forKey: "notification")
                    }
                }
            }
            
            //MARK: Save to CoreData
            
            if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                if let data = self.getNotification(userInfo: aps) {
                    let msg = Message(context: self.coreDataManager.mainManagedObjectContext)
                    msg.title = data.0
                    msg.body = data.1
                    self.coreDataManager.saveChanges()
                }
            }
            
            //MARK: Modfiy Notification
            
            guard let body = bestAttemptContent.userInfo["fcm_options"] as? Dictionary<String, Any>, let imageUrl = body["image"] as? String else { fatalError("Image Link not found") }
            downloadImageFrom(url: imageUrl) { (attachment) in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    bestAttemptContent.categoryIdentifier = "myNotificationCategory"
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    //MARK: - Parse Notification JSON
    
    private func getNotification(userInfo: [String: Any]) -> (String, String)? {
        guard let notification = userInfo["alert"] as? [String: Any] else { return nil }
        if let title = notification["title"] as? String, let body = notification["body"] as? String {
            return (title, body)
        }
        return nil
    }
    
    //MARK: - Image Downloader
    
    private func downloadImageFrom(url: String, handler: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: URL(string: url)!) { (downloadedUrl, response, error) in
            guard let downloadedUrl = downloadedUrl else { handler(nil) ; return }
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            let uniqueUrlEnding = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            urlPath = urlPath.appendingPathComponent(uniqueUrlEnding)
            try? FileManager.default.moveItem(at: downloadedUrl, to: urlPath)
            do {
                let attachment = try UNNotificationAttachment(identifier: "picture", url: urlPath, options: nil)
                handler(attachment)
            } catch {
                print("attachment error")
                handler(nil)
            }
        }
        task.resume()
    }
    
    //MARK: - 
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
