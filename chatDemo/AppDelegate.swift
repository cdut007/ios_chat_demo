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
      //  chatModel.login(userId: <#String#>);
          // Override point for customization after application launch.
                //initBasicSessionV3();
            //   let content = messageEncryptHelper.encrypt("zq30695873350b443bbc992c691e525201","zqc1f7b4b49d4641e8b76ae3a59cd25a0f","似懂非懂ase😄");
              //    let decryptedString = decrypt("zqc1f7b4b49d4641e8b76ae3a59cd25a0f",content);
        //       let decryptedString = messageEncryptHelper.decrypt( "zqc1f7b4b49d4641e8b76ae3a59cd25a0f","MwohBWYDxKRsPsooQ9gQYaH7ODBxe1S8YjgQZYabprZODe8KEAAYACKwATm+CPwVeWeYMvpnfXEJsb473+q8PqD62bc+IUawpvtiFPkKqrV0+xhTLaDmDuje7J+wZdJktZCMW3f1E1gOsf3LidxppD1R10+pAqk5G95fr22ylEoMhkhGAVELjal/JSVVwVI7KX26Q9UBtOzPzHeYxpDZZseWq7uwsau0IhWNCZe27e4WhSAHSrw0YxHwO8bixZsXpXYHWwTxksd3y51pLa6wEttkxfiGOklPecDQP7v7hcvN/YQ=.FCtcBCAMSIQU+tBrH+5Sg1oweEtQx0xnHm4uLXWZ2/8UUx0EV8Cs8exohBYgtTEGwcIRQd5wfEIQEnRNK5OdsYxyZDqH26ssBv55DIiBVd4EvCaMRyXJLNmiBPTTDd4HM41Oe91a9MFgDMsMegzJrCiEFtn9brxsNoMhrtOk3McPK5igoyL1uHi3rB4/XxUPcSV4SIJDSKQHb3yfHQyNBFpAEtEhGcUrfJUdgzPedZz89poNbGiQIABIgtJe2InladeEeZKpLUkoS+1sJRrVTT51mlBuIc+dxd6U=");
             //   let test = decryptedString + "1"
              
        return true
    }

    // MARK: UISceneSession Lifecycle

  


}

