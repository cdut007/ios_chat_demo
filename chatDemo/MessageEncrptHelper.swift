//
//  MessageEncrptHelper.swift
//  chatDemo
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 mac. All rights reserved.
//


import SignalProtocol


class MessageEncryptHelper{
    
    
         func decrypt(_ userId:String,_ encryptMsg:String) ->String{
           
           
            return Signal.decryptMessage(encryptMsg: encryptMsg,senderName:userId)
        }
        
  
    
         func encrypt(_ senderId:String,_ receiverId:String, _ content:String) -> String{
              
              
            let encryptMsg = Signal.encryptMessage(currentUser: senderId,receiverName: receiverId,orignalMsg: content)
           
            return encryptMsg;

        }
    
}
