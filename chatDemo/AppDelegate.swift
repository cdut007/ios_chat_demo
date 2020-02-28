//
//  AppDelegate.swift
//  chatDemo
//
//  Created by mac on 2020/1/6.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import TigaseSwift
import SignalProtocol
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var chatModel = ChatModel.shareInstence();
    
  
    
    @objc func methodOfReceivedNotification(notification: Notification) {
     // Take Action on Notification
        print(notification)
        let status = notification.object as! NSDictionary
        if "connected" == status["status"] as! String
        {
            let text = "test111";
                                       let content = "{\"messageType\":\"TextMessage\",\"messageTypeValue\":1,\"data\":{\"content\":\""+text+"\"},\"messageEncrypt\":\"true\",\"peerInfo\":{\"userName\":\"\",\"mobile\":\"\",\"nickName\":\"\"}}";
//            self.chatModel.sendCustomMessage(chatId:"private-chat-e72d0bed-54f9-4e00-b295-e9a4f482842e", jsonData:content,conversationType: ChatModel.ConversationType.GROUP_CHAT.rawValue);
          
//                                       self.chatModel.sendCustomMessage(chatId:"zq30695873350b443bbc992c691e525201", jsonData:content,conversationType: ChatModel.ConversationType.SINGLE_CHAT.rawValue);
//              self.chatModel.kickGroupMember(chatId: "private-chat-e72d0bed-54f9-4e00-b295-e9a4f482842e", memberId: "zqe04443e1010b41e7b254f0d9fb527933")
         //   self.chatModel.joinGroup(chatId: "private-chat-e72d0bed-54f9-4e00-b295-e9a4f482842e")
            self.chatModel.inviteToGroup(chatId: "private-chat-e72d0bed-54f9-4e00-b295-e9a4f482842e",memberId:"zq30695873350b443bbc992c691e525201")
        }
   }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("LoginStatusChangedNotify"), object: nil)
        
        chatModel.encrypt=true
        chatModel.login(userId: "zqe04443e1010b41e7b254f0d9fb527933", token: "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6InpxZTA0NDQzZTEwMTBiNDFlN2IyNTRmMGQ5ZmI1Mjc5MzMiLCJ0eXBlIjoidXNlciIsImV4cCI6MTU4Mjk4Nzc2NSwiaWF0IjoxNTgyOTAxMzY1fQ.swUIP7e9Orx1MXX3ryPhvUK9stmGdGMwgOa4G05yS20", imHost: "47.94.10.136", imPort: 5221, domain: "ul");
        let conversations = chatModel.getAllConversations()
        if(conversations.count>0)
        {
            let conversation = conversations[0]
            chatModel.getMessages(conversationKeyId: conversation["id"] as! Int, msgKeyId: -1, count: 10, prevOrNext: true)
        }

              
        return true
    }

    // MARK: UISceneSession Lifecycle

  


}

