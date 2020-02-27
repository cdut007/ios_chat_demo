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
        let conversation_sql = "CREATE TABLE IF NOT EXISTS 'conversation' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'conversation_id' TEXT UNIQUE NOT NULL,'title' text,'content' text,'json_data' text,'message_id' text,'message_count' integer default 0,'unread_message_count' integer default 0,'mute' integer default 0,'set_top_time' TimeStamp,'set_top' integer default 0,'conversation_type' integer default -1,'status' text,'local_date'  TimeStamp not null default (datetime('now', 'localtime')), 'error_info' text);"
        var createOk =  execSql(sql: conversation_sql)
        if(!createOk){
            print("创建会话表失败")
            return false
        }
        let message_sql = "CREATE TABLE IF NOT EXISTS 'message' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'message_id' TEXT UNIQUE NOT NULL,'conversation_id' text,'content' text,'json_data' text,'sender_id' text,'receiver_id' text,'send_status' text,'type' integer default -1, message_read  integer default 0,'conversation_keyid' integer default -1, 'local_date' TimeStamp,'to_language' text,'conversation_type' text,'status' text,'server_date'  TimeStamp not null default (datetime('now', 'localtime')), 'error_info' text);"
        createOk =  execSql(sql: message_sql)
        if(!createOk){
            print("创建消息表失败")
            return false
        }
        
        let  member_sql = "CREATE TABLE IF NOT EXISTS 'group_member' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'conversation_id' TEXT UNIQUE NOT NULL,'user_id' text, is_owner integer default 0,'local_date' TimeStamp,'json_data' text);"
        createOk =  execSql(sql: member_sql)
        if(!createOk){
            print("创建会话成员表失败")
            return false
        }
        print("创建表成功")
        return true
    }
    private func sqlite3_column_str(_ queryStatement:OpaquePointer?,_ index:Int32) ->String{
        let emptyStr = [UInt8]("".utf8)
        var info = sqlite3_column_text(queryStatement, index)
        if info != nil {
            let content = String(cString: info!)
             return content
        }
        return ""
    }
    private func parseConversationFromCuror(queryStatement: OpaquePointer?)-> NSDictionary{
        // 3
        var conversation: [String: Any] = [:]
        let id = sqlite3_column_int(queryStatement, 0)
        conversation["id"] = id
        // 4
        let conversation_id = sqlite3_column_str(queryStatement, 1)
        conversation["conversationId"] = conversation_id
        
        let title = sqlite3_column_str(queryStatement, 2)
        conversation["title"] = title
        conversation["draft"] = sqlite3_column_str(queryStatement, 3)
        let json_data = sqlite3_column_str(queryStatement, 4)
        conversation["jsonData"] = json_data
        
        let message_id = sqlite3_column_str(queryStatement, 5)
        if(!message_id.isEmpty){
            let lastMessage = getMessageBykeyIdOrGlobalId(keyId:-1,globalMsgId:message_id)
            conversation["lastMessage"] = lastMessage
        }
       
        let msgCount = sqlite3_column_int(queryStatement, 6)
        conversation["msgCount"] = msgCount
        let unreadMsgCount = sqlite3_column_int(queryStatement, 7)
        conversation["unreadMsgCount"] = unreadMsgCount
        let mute = sqlite3_column_int(queryStatement, 8)
        conversation["mute"] = mute
        let set_top_time = sqlite3_column_str(queryStatement, 9)
        conversation["setTopTime"] = set_top_time
        let set_top = sqlite3_column_int(queryStatement, 10)
        conversation["setTop"] = set_top
        let conversation_type = sqlite3_column_int(queryStatement, 11)
        conversation["conversationType"] = conversation_type
        let status = sqlite3_column_str(queryStatement, 12)
        conversation["status"] = status
        let local_date = sqlite3_column_str(queryStatement, 13)
        conversation["localDate"] = local_date
        let error_info = sqlite3_column_str(queryStatement, 14)
        conversation["errorInfo"] = error_info
        
        
        print("\nQuery conversation Result:")
        print("\(conversation)")
        return conversation as NSDictionary
    }
    
    private func parseMessageFromCuror(queryStatement: OpaquePointer?)-> NSDictionary{
        // 3
        var message: [String: Any] = [:]
        let id = sqlite3_column_int(queryStatement, 0)
        message["id"] = id
        // 4
        let message_id = sqlite3_column_str(queryStatement, 1)
        message["messageId"] = message_id
        
        let conversation_id = sqlite3_column_str(queryStatement, 2)
        message["convsationId"] = conversation_id
        
        let content = sqlite3_column_str(queryStatement, 3)
        message["content"] = content
        
        let json_data = sqlite3_column_str(queryStatement, 4)
        message["jsonData"] = json_data
        
        let sender_id = sqlite3_column_str(queryStatement, 5)
        message["senderId"] = sender_id
        let receiver_id = sqlite3_column_str(queryStatement, 6)
        message["receiverId"] = receiver_id
        let send_status = sqlite3_column_str(queryStatement, 7)
        let type = sqlite3_column_int(queryStatement, 8)
        message["type"] = type
        let message_read = sqlite3_column_int(queryStatement, 9)
        message["isRead"] = message_read
        let conversation_keyid = sqlite3_column_int(queryStatement, 10)
        message["conversationKeyId"] = conversation_keyid
        let local_date = sqlite3_column_str(queryStatement, 11)
        message["localDate"] = local_date
        let to_language = sqlite3_column_str(queryStatement, 12)
        message["toLanguage"] = to_language
        let conversation_type = sqlite3_column_str(queryStatement, 13)
        message["conversationType"] = conversation_type
        let status = sqlite3_column_str(queryStatement, 14)
        message["status"] = Int(status)
        let server_date = sqlite3_column_str(queryStatement, 15)
        let error_info = sqlite3_column_str(queryStatement, 16)
        message["errorInfo"] = error_info
        print("\nQuery message Result:")
        print("\(message)")
        return message as NSDictionary
    }
    
    func getConversationByKeyIdOrGlobalId(keyId:Int,chatId:String) -> NSDictionary?{
        var queryStatement: OpaquePointer?
        var convsation:NSDictionary?
        // 1
        var queryStatementString="SELECT * FROM conversation WHERE conversation_id = \(keyId)"
        if(keyId == -1){
            queryStatementString="SELECT * FROM conversation WHERE conversation_id = '\(chatId)'"
        }
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
    
    func getMessageBykeyIdOrGlobalId(keyId:Int,globalMsgId:String) -> NSDictionary?{
        var queryStatement: OpaquePointer?
        var message:NSDictionary?
        // 1
        var queryStatementString="SELECT * FROM message WHERE message_id = \(keyId)"
        if(keyId == -1){
            queryStatementString="SELECT * FROM message WHERE message_id = '\(globalMsgId)'"
        }
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) ==
            SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                message=parseMessageFromCuror(queryStatement: queryStatement)
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
        return message
    }
    
    func  getAllConversations() -> Array<NSDictionary>{
        var conversations: [NSDictionary] = []
        let queryStatementString = "SELECT * FROM conversation order by local_date desc";
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            queryStatementString,
            -1,
            &queryStatement,
            nil
            ) == SQLITE_OK {
            print("\n")
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                conversations.append(parseConversationFromCuror(queryStatement:queryStatement))
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n getAllConversations Query is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        
        return conversations
        
    }
    
    func  getMessages(conversationKeyId:Int,msgKeyId:Int,count:Int,prevOrNext:Bool) -> Array<NSDictionary>{
        var messages: [NSDictionary] = []
        var queryStatementString = "SELECT * FROM message WHERE conversation_keyid=\(conversationKeyId) order by local_date desc, id desc limit \(count)"
        if(msgKeyId != -1){
            var beside_ = ">=";
            if (prevOrNext) {
                beside_ = "<=";
                }
            queryStatementString = "select * from(select * from message where conversation_keyid = \(conversationKeyId) and local_date \(beside_) (select local_date from message where id = \(msgKeyId)) order by local_date desc, id desc limit \(count)) order by local_date, id"
        }
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            queryStatementString,
            -1,
            &queryStatement,
            nil
            ) == SQLITE_OK {
            print("\n")
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                messages.append(parseMessageFromCuror(queryStatement:queryStatement))
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n getAllConversations Query is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
        
        return messages
        
    }
    
    func createConversationById(chatId:String,convsationType:Int,title:String) -> Bool {
        
        let sql = "INSERT INTO conversation (conversation_type,local_date,conversation_id,title) VALUES (?, ?, ?, ?);"
        if  !initedReady {
            print("数据库初始化失败："+sql)
            return false
        }
        
        var execOk = false
        var insertStatement: OpaquePointer?
        // 1
        if sqlite3_prepare_v2(db, sql, -1, &insertStatement, nil) ==
            SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(convsationType))
            sqlite3_bind_text(insertStatement, 2, "\(CLongLong(round(Date().timeIntervalSince1970*1000)))",  -1, nil)
            sqlite3_bind_text(insertStatement, 3, convertUtf8Str(chatId), -1, nil)
            sqlite3_bind_text(insertStatement, 4, convertUtf8Str(title), -1, nil)
            
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
    
    private func postNotifition(actName:String,data:Any){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:actName), object: data)
    }
    
    private func convertUtf8Str(_ text:String)->UnsafePointer<Int8>?{
        
        let nsStr = text as NSString
        let cstr =   nsStr.utf8String
        return cstr
    }
    
    func insertMessage(data:NSDictionary,chatId:String,from:String,to:String,globalMsgId:String,jsonData:String,convsationType:Int, errorInfo:String) -> Bool {
        
        let sql = "INSERT INTO message (conversation_type, json_data, sender_id, message_id,type,local_date,receiver_id,error_info,message_read,status,send_status,conversation_id,conversation_keyid,content) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        if  !initedReady {
            print("数据库初始化失败："+sql)
            return false
        }
        
        //check conversation exsit first.
        var conversion = getConversationByKeyIdOrGlobalId(keyId:-1,chatId: chatId)
        if(conversion == nil){
            createConversationById(chatId:chatId,convsationType:convsationType,title:"")
            conversion = getConversationByKeyIdOrGlobalId(keyId:-1,chatId: chatId)
        }
        var execOk = false
        var insertStatement: OpaquePointer?
        var incomingMsg = false
        // 1
        if sqlite3_prepare_v2(db, sql, -1, &insertStatement, nil) ==
            SQLITE_OK {
            var msgTypeValue = data["messageTypeValue"] as! Int;
            let messageType = ChatModel.MessageType(rawValue:msgTypeValue)!
            let dataInfo = data["data"] as! NSDictionary
            var content = ""
            if(messageType == ChatModel.MessageType.MESSAGE_TYPE_TEXT){
                content = dataInfo["content"] as! String
            }else if(messageType == ChatModel.MessageType.MESSAGE_TYPE_FILE){
                content = dataInfo["fileName"] as! String
            }
            
           
            // 2
            sqlite3_bind_int(insertStatement, 1, Int32(convsationType))
            
            sqlite3_bind_text(insertStatement, 2, convertUtf8Str(jsonData), -1, nil)
            sqlite3_bind_text(insertStatement, 3, convertUtf8Str(from), -1, nil)
            sqlite3_bind_text(insertStatement, 4, convertUtf8Str(globalMsgId), -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(msgTypeValue))
            sqlite3_bind_text(insertStatement, 6, convertUtf8Str("\(CLongLong(round(Date().timeIntervalSince1970*1000)))"),  -1, nil)
            sqlite3_bind_text(insertStatement, 7, convertUtf8Str(to), -1, nil)
            sqlite3_bind_text(insertStatement, 8, convertUtf8Str(errorInfo), -1, nil)
            let userId = ChatModel.shareInstence().userId
            
            if (userId != from || messageType == ChatModel.MessageType.MESSAGE_TYPE_TIPS || messageType == ChatModel.MessageType.MESSAGE_TYPE_SYSTEM) {
                //incoming message.
                incomingMsg = true
                sqlite3_bind_int(insertStatement, 9, 0)
                sqlite3_bind_text(insertStatement, 10,  convertUtf8Str("\(ChatModel.MessageStatus.STATUS_OK.rawValue)"), -1, nil)
                sqlite3_bind_text(insertStatement, 11, convertUtf8Str("done"), -1, nil)
                
            } else {
                sqlite3_bind_int(insertStatement, 9, 1)
                sqlite3_bind_text(insertStatement, 10, convertUtf8Str("\(ChatModel.MessageStatus.STATUS_IN_PROGRESS.rawValue)"), -1, nil)
                sqlite3_bind_text(insertStatement, 11, convertUtf8Str("create"), -1, nil)
                
            }
            sqlite3_bind_text(insertStatement, 12, convertUtf8Str(chatId), -1, nil)
            sqlite3_bind_int(insertStatement, 13, conversion?["id"] as! Int32)
            sqlite3_bind_text(insertStatement, 14, convertUtf8Str(content), -1, nil)
            
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
            let msgCount = conversion?["msgCount"]as! Int32 + 1
            var unreadMsgCount = conversion?["msgCount"]as! Int32
            if(incomingMsg){
                unreadMsgCount = unreadMsgCount + 1
            }
            let updateResult =  updataData(sql:"UPDATE conversation SET message_count = \(msgCount), unread_message_count = \(unreadMsgCount),message_id = '\(globalMsgId)',local_date = '\(CLongLong(round(Date().timeIntervalSince1970*1000)))' WHERE id = \(conversion?["id"]as! Int32);")
            if(updateResult){
                //sendNotify
                postNotifition(actName: "MessageIncomingNotify",data: getMessageBykeyIdOrGlobalId(keyId:-1,globalMsgId:globalMsgId))
            }
            
        }
        return execOk
    }
    
    func updateMsgBody(globalMsgId:String,body:String) ->Bool {
           var updateStatus = false
        
            updateStatus = updataData(sql:"UPDATE message SET json_data = '\(body)' where message_id = \(globalMsgId)")
         
           if(updateStatus){
               //sendNotify
               postNotifition(actName: "MessageStatusChangedNotify",data: getMessageBykeyIdOrGlobalId(keyId:-1,globalMsgId:globalMsgId))
           }
           return updateStatus
       }
    
    func updateMsgStatus(globalMsgId:String,status:Int,timestamp:String) ->Bool {
        var updateStatus = false
        
        if(timestamp.isEmpty){
              updateStatus = updataData(sql:"UPDATE message SET status = \(status), local_date = \(timestamp), server_date = \(timestamp) where message_id = \(globalMsgId)")
        }else{
              updateStatus = updataData(sql:"UPDATE message SET status = \(status) where message_id = \(globalMsgId)")
        }
      
        if(updateStatus){
            //sendNotify
            postNotifition(actName: "MessageStatusChangedNotify",data: getMessageBykeyIdOrGlobalId(keyId:-1,globalMsgId:globalMsgId))
        }
        return updateStatus
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
    
    func createNewMsg(chatId:String,from:String,to:String,globalMsgId:String,jsonData:String,convsationType:Int, errorInfo:String) -> Bool{
        
        let dict = getDictionaryFromJSONString(jsonString: jsonData)
        
        return insertMessage(data:dict,chatId:chatId,from:from,to:to,globalMsgId:globalMsgId,jsonData:jsonData,convsationType:convsationType, errorInfo:errorInfo);
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

