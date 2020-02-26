//
//  ChatStore.swift
//  chatDemo
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 mac. All rights reserved.
//


import Foundation
import SQLite3

class ChatStoreDB: NSObject {
    var db:OpaquePointer? = nil
    static let instance = ChatStoreDB()
    class func shareInstence() -> ChatStoreDB {
        return instance
    }
    var initedReady=false;
    func openDB(_userId:String) -> Bool {
        let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        print(filePath)
        let file = filePath + "/"+_userId+"_chatIMDB.db"
        let cfile = file.cString(using: String.Encoding.utf8)
        let state = sqlite3_open(cfile,&db)
        if state != SQLITE_OK{
            print("打开数据库失败")
            return false
        }
        //创建表
        if(creatTables()){
            initedReady=true;
        }
        return initedReady
    }
    
    func closeDB(){
        sqlite3_close(db)
    }
    
    func creatTables() -> Bool {
        let conversation_sql = "CREATE TABLE IF NOT EXISTS 'conversation' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'conversation_id' TEXT UNIQUE NOT NULL,'title' text,'content' text,'json_data' text,'messageId' text,'message_count' integer default 0,'unread_message_count' integer default 0,'mute' integer default 0,'set_top_time' TimeStamp,'set_top' integer default 0,'conversation_type' integer default -1,'status' text,'local_date'  TimeStamp not null default (datetime('now', 'localtime')), 'error_info' text);"
        var createOk =  execSql(sql: conversation_sql)
        if(!createOk){
            print("创建会话表失败")
            return false
        }
        let message_sql = "CREATE TABLE IF NOT EXISTS 'conversation' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'conversation_id' TEXT UNIQUE NOT NULL,'title' text,'content' text,'json_data' text,'messageId' text,'message_count' integer default 0,'unread_message_count' integer default 0,'mute' integer default 0,'set_top_time' TimeStamp,'set_top' integer default 0,'conversation_type' integer default -1,'status' text,'local_date'  TimeStamp not null default (datetime('now', 'localtime')), 'error_info' text);"
        createOk =  execSql(sql: message_sql)
        if(!createOk){
            print("创建消息表失败")
            return false
        }
        
        let  member_sql = "CREATE TABLE IF NOT EXISTS 'message' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'message_id' TEXT UNIQUE NOT NULL,'conversation_id' text,'content' text,'json_data' text,'sender_id' text,'receiver_id' text,'send_status' text,'type' integer default -1, message_read  integer default 0,'conversation_keyid' integer default -1, 'local_date' TimeStamp,'to_language' text,'conversation_type' text,'status' text,'server_date'  TimeStamp not null default (datetime('now', 'localtime')), 'error_info' text);"
        createOk =  execSql(sql: member_sql)
        if(!createOk){
            print("创建会话成员表失败")
            return false
        }
        print("创建表成功")
        return true
    }
    
    private func parseConversationFromCuror(queryStatement: OpaquePointer?)-> NSDictionary{
        // 3
        var convsation: [String: Any] = [:]
        let id = sqlite3_column_int(queryStatement, 0)
        convsation["id"] = id
        // 4
        let conversation_id = String(cString: sqlite3_column_text(queryStatement, 1))
        print("\nQuery Result:")
        print("\(id) | \(conversation_id)")
        return convsation as NSDictionary
    }
    
    func getConversationById(chatId:String) -> NSDictionary?{
        var queryStatement: OpaquePointer?
        var convsation:NSDictionary?
        // 1
        let queryStatementString="SELECT * FROM conversation WHERE conversation_id = '\(chatId)'"
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) ==
            SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                convsation=parseConversationFromCuror(queryStatement: queryStatement)
            } else {
                print("\nQuery returned no results.")
            }
        } else {
            // 6
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuery is not prepared \(errorMessage)")
        }
        // 7
        sqlite3_finalize(queryStatement)
        return convsation
    }
    
    func createConversationById(chatId:String,title:String) -> Bool {
        //let uuid = UUID().uuidString
        let sql = "INSERT INTO message (conversation_type, json_data, sender_id, message_id,type,local_date,receiver_id,error_info,message_read,send_status,status,conversation_id,conversation_keyid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        if  !initedReady {
            print("数据库初始化失败："+sql)
            return false
        }
        
        //check conversation exsit first.
        var conversion = getConversationById(chatId: chatId)
        
        var execOk = false
        var insertStatement: OpaquePointer?
        // 1
        if sqlite3_prepare_v2(db, sql, -1, &insertStatement, nil) ==
            SQLITE_OK {
            var msgTypeValue = data["messageTypeValue"] as! Int;
            let messageType = ChatModel.MessageType(rawValue:msgTypeValue)!
            // 2
            sqlite3_bind_int(insertStatement, 1, Int32(convsationType))
            sqlite3_bind_text(insertStatement, 2, jsonData, -1, nil)
            sqlite3_bind_text(insertStatement, 3, from, -1, nil)
            sqlite3_bind_text(insertStatement, 4, globalMsgId, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(msgTypeValue))
            sqlite3_bind_text(insertStatement, 6, "\(Date().timeIntervalSince1970)",  -1, nil)
            sqlite3_bind_text(insertStatement, 7, to, -1, nil)
            sqlite3_bind_text(insertStatement, 8, errorInfo, -1, nil)
            let userId = ChatModel.shareInstence().userId
            var incomingMsg = false
            if (userId != from || messageType == ChatModel.MessageType.MESSAGE_TYPE_TIPS || messageType == ChatModel.MessageType.MESSAGE_TYPE_SYSTEM) {
                //incoming message.
                incomingMsg = true
                sqlite3_bind_int(insertStatement, 9, 0)
                sqlite3_bind_text(insertStatement, 10, "\(ChatModel.MessageStatus.STATUS_OK.rawValue)", -1, nil)
                sqlite3_bind_text(insertStatement, 11, "done", -1, nil)
                
            } else {
                sqlite3_bind_int(insertStatement, 9, 1)
                sqlite3_bind_text(insertStatement, 10,"\(ChatModel.MessageStatus.STATUS_IN_PROGRESS.rawValue)", -1, nil)
                sqlite3_bind_text(insertStatement, 11, "create", -1, nil)
                
            }
            sqlite3_bind_text(insertStatement, 12, chatId, -1, nil)
            sqlite3_bind_int(insertStatement, 13, conversion?["id"] as! Int32)
            // 3
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print(sql+"\nSuccessfully inserted row.")
                execOk = true
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print(sql+"\n insert is not done! \(errorMessage)")
                print(sql+"\nCould not insert row.")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print(sql+"\n insert is not prepared! \(errorMessage)")
        }
        // 5
        sqlite3_finalize(insertStatement)
        if(execOk){
            //sendNotify
        }
        return execOk
    }
    
    func insertMessage(data:NSDictionary,chatId:String,from:String,to:String,globalMsgId:String,jsonData:String,convsationType:Int, errorInfo:String) -> Bool {
        //let uuid = UUID().uuidString
        let sql = "INSERT INTO message (conversation_type, json_data, sender_id, message_id,type,local_date,receiver_id,error_info,message_read,send_status,status,conversation_id,conversation_keyid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        if  !initedReady {
            print("数据库初始化失败："+sql)
            return false
        }
        
        //check conversation exsit first.
        var conversion = getConversationById(chatId: chatId)
        if(conversion == nil){
            createConversationById(chatId:chatId,title:"")
            conversion = getConversationById(chatId: chatId)
        }
        var execOk = false
        var insertStatement: OpaquePointer?
        // 1
        if sqlite3_prepare_v2(db, sql, -1, &insertStatement, nil) ==
            SQLITE_OK {
            var msgTypeValue = data["messageTypeValue"] as! Int;
            let messageType = ChatModel.MessageType(rawValue:msgTypeValue)!
            // 2
            sqlite3_bind_int(insertStatement, 1, Int32(convsationType))
            sqlite3_bind_text(insertStatement, 2, jsonData, -1, nil)
            sqlite3_bind_text(insertStatement, 3, from, -1, nil)
            sqlite3_bind_text(insertStatement, 4, globalMsgId, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(msgTypeValue))
            sqlite3_bind_text(insertStatement, 6, "\(Date().timeIntervalSince1970)",  -1, nil)
            sqlite3_bind_text(insertStatement, 7, to, -1, nil)
            sqlite3_bind_text(insertStatement, 8, errorInfo, -1, nil)
            let userId = ChatModel.shareInstence().userId
            var incomingMsg = false
            if (userId != from || messageType == ChatModel.MessageType.MESSAGE_TYPE_TIPS || messageType == ChatModel.MessageType.MESSAGE_TYPE_SYSTEM) {
                //incoming message.
                incomingMsg = true
                sqlite3_bind_int(insertStatement, 9, 0)
                sqlite3_bind_text(insertStatement, 10, "\(ChatModel.MessageStatus.STATUS_OK.rawValue)", -1, nil)
                sqlite3_bind_text(insertStatement, 11, "done", -1, nil)
                
            } else {
                sqlite3_bind_int(insertStatement, 9, 1)
                sqlite3_bind_text(insertStatement, 10,"\(ChatModel.MessageStatus.STATUS_IN_PROGRESS.rawValue)", -1, nil)
                sqlite3_bind_text(insertStatement, 11, "create", -1, nil)
                
            }
            sqlite3_bind_text(insertStatement, 12, chatId, -1, nil)
            sqlite3_bind_int(insertStatement, 13, conversion?["id"] as! Int32)
            // 3
            
            // 4
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print(sql+"\nSuccessfully inserted row.")
                execOk = true
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print(sql+"\n insert is not done! \(errorMessage)")
                print(sql+"\nCould not insert row.")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print(sql+"\n insert is not prepared! \(errorMessage)")
        }
        // 5
        sqlite3_finalize(insertStatement)
        if(execOk){
            //sendNotify
        }
        return execOk
    }
    
    func execSql(sql:String) -> Bool {
        
        // 1
        var createTableStatement: OpaquePointer?
        var execOk = false
        // 2
        if sqlite3_prepare_v2(db, sql, -1, &createTableStatement, nil) ==
            SQLITE_OK {
            // 3
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print(sql+"\n  exec Ok.")
                execOk = true
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print(sql+"\n exec is not done! \(errorMessage)")
                
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print(sql+"\n exec is not prepared! \(errorMessage)")
        }
        // 4
        sqlite3_finalize(createTableStatement)
        return execOk
    }
    
    func updataData(sql:String) -> Bool {
        print("更新表："+sql)
        if  !initedReady {
            print("数据库初始化失败："+sql)
            return false
        }
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &updateStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print(sql+"\nSuccessfully updated row.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                
                print(sql+"\nCould not update row.\(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            
            print(sql+"\nUPDATE statement is not prepared\(errorMessage)")
        }
        sqlite3_finalize(updateStatement)
        return true
    }
    func deleteData(sql:String) {
        
        if execSql(sql: sql) {
            print("删除成功")
        }else{
            print("删除失败")
        }
    }
    
    func createNewMsg(chatId:String,from:String,to:String,globalMsgId:String,jsonData:String,convsationType:Int, errorInfo:String) -> NSDictionary{
        
        let dict = getDictionaryFromJSONString(jsonString: jsonData)
        insertMessage(data:dict,chatId:chatId,from:from,to:to,globalMsgId:globalMsgId,jsonData:jsonData,convsationType:convsationType, errorInfo:errorInfo)
        return dict;
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> NSString {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString!
    }
    
}

