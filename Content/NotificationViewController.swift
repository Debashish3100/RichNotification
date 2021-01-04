//
//  NotificationViewController.swift
//  Content
//
//  Created by Debashish Das on 05/10/20.
//  Copyright © 2020 sambit. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var bodyLabel: UILabel?
    @IBOutlet weak var image: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    func didReceive(_ notification: UNNotification) {
        //self.label?.text = notification.request.content.body
        self.titleLabel?.text = notification.request.content.title
        self.bodyLabel?.text = notification.request.content.body
        //let attachments = notification.request.content.attachments
//        var urlImage: String?
//        if let body = notification.request.content.userInfo["fcm_options"] as? Dictionary<String, Any> {
//            if let imageUrl = body["image"] as? String {
//                urlImage = imageUrl
//            } else { print("image failed") }
//        } else { print("fcm failed") }
        guard let body = notification.request.content.userInfo["fcm_options"] as? Dictionary<String, Any>, let imageUrl = body["image"] as? String else { fatalError("Image Link not found") }
        guard let url = URL(string: imageUrl) else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        image?.image = UIImage(data: imageData)
//        for attachment in attachments {
//            if attachment.identifier == "picture" {
//                print("image Url : \(attachment.url)")
//                guard let data = try? Data(contentsOf: attachment.url) else { return }
//                image?.image = UIImage(data: data)
//            }
//        }
    }
//fzDkZul4XU1vjkJZJSaICH:APA91bFbTdCXt42D0GYjcqxl8o8BNOxGxSnpaEosrUgp-s9gB8Eps0Pef0iOxVocuCJc_9NtY66hLLzeMFIu3-vDM79FoY7ttm2RuPXgAND-dbjNS18n1_e99CCfvCWDh1IioWh4G-SR
    
}
