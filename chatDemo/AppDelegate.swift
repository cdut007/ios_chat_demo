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
    
  
    
   

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        chatModel.login(userId: "zqe04443e1010b41e7b254f0d9fb527933", token: "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6InpxZTA0NDQzZTEwMTBiNDFlN2IyNTRmMGQ5ZmI1Mjc5MzMiLCJ0eXBlIjoidXNlciIsImV4cCI6MTU4MjkwMTI5MCwiaWF0IjoxNTgyODE0ODkwfQ.bb3GiXUr3dCmzMYuUdQX6aKIYGV8CRlVx6Fw-knSlBo", imHost: "47.94.10.136", imPort: 5221, domain: "ul");
        let conversations = chatModel.getAllConversations()
        if(conversations.count>0)
        {
            let conversation = conversations[0]
            chatModel.getMessages(conversationKeyId: conversation["id"] as! Int, msgKeyId: -1, count: 10, prevOrNext: true)
        }
//        let text = "test111";
//                           let content = "{\"messageType\":\"TextMessage\",\"messageTypeValue\":1,\"data\":{\"content\":\""+text+"\"},\"messageEncrypt\":\"true\",\"peerInfo\":{\"userName\":\"\",\"mobile\":\"\",\"nickName\":\"\"}}";
//                           self._chatModel.sendCustomMessage(chatId:"private-chat-195f0510-119f-4b9c-8c41-14b9b561adb5", jsonData:content,conversationType: ConversationType.GROUP_CHAT.rawValue);
//
//                           self._chatModel.sendCustomMessage(chatId:"zq30695873350b443bbc992c691e525201", jsonData:content,conversationType: ConversationType.SINGLE_CHAT.rawValue);
              
        return true
    }

    // MARK: UISceneSession Lifecycle

  


}

