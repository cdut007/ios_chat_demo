//
//  AppDelegate.swift
//  chatDemo
//
//  Created by mac on 2020/1/6.
//  Copyright © 2020 mac. All rights reserved.
//
import UIKit
import TigaseSwift

class ChatModel:NSObject {
    static let instance = ChatModel()
    class func shareInstence() -> ChatModel {
        return instance
    }
    var client = XMPPClient();
    var messageEncryptHelper = MessageEncryptHelper();
    public var userId:String = "";
    public var domain:String = "";
    public var resource:String = "call";
    public var encrypt = false;
    
    enum ConversationType: Int {
        case SINGLE_CHAT = 1, GROUP_CHAT, SYSTEM_CHAT
    }
    
    enum MessageType:Int{
        case MESSAGE_TYPE_DRAFT = 0,MESSAGE_TYPE_TEXT ,MESSAGE_TYPE_FILE,MESSAGE_TYPE_IMAGE,
        MESSAGE_TYPE_CUSTOM,MESSAGE_TYPE_LOCATION, MESSAGE_TYPE_VOICE,MESSAGE_TYPE_VCARD, MESSAGE_TYPE_TIPS,
        MESSAGE_TYPE_STICKER,MESSAGE_TYPE_EVENT,MESSAGE_TYPE_SUBSCRIBE,MESSAGE_TYPE_VOIP ,
        MESSAGE_TYPE_SYSTEM ,MESSAGE_TYPE_SHARE_LINK ,MESSAGE_TYPE_PUSH ,MESSAGE_TYPE_UNKNOWN
    }
    
    enum MessageStatus:Int{
        case STATUS_OK=0,STATUS_READ,STATUS_DRAFT,STATUS_DELIVERY_OK,STATUS_FAILURE ,STATUS_IN_PROGRESS
    }
    
    func insertCustomMessage(chatId:String,from:String,to:String,jsonData:String,conversationType:Int){
        let uuid = UUID().uuidString
        let createLocalMsg = ChatStoreDB.shareInstence().createNewMsg(chatId: chatId, from: from, to: to, globalMsgId: uuid, jsonData: jsonData, convsationType: conversationType, errorInfo: "")
        if(createLocalMsg){
            ChatStoreDB.shareInstence().updateMsgStatus(globalMsgId:uuid,status: MessageStatus.STATUS_OK.rawValue,timestamp: "")
        }
    }
    
    func setEncrypt(encrypt:Bool){
        self.encrypt = encrypt
    }
    
    func isLogin() -> Bool{
        return client.state == SocketConnector.State.connected
    }
    
    func deleteConversation(keyId: Int) -> Bool{
        return ChatStoreDB.shareInstence().deleteConversation(keyId: keyId)
    }
    
    func deleteMessage(msgKeyId: Int) -> Bool{
        return ChatStoreDB.shareInstence().deleteMessage(msgKeyId: msgKeyId)
    }
    
    func messageRead(keyId:Int) -> Bool{
        return ChatStoreDB.shareInstence().messageRead(keyId: keyId)
    }
    func conversationRead(keyId:Int) -> Bool {
        return ChatStoreDB.shareInstence().conversationRead(keyId: keyId)
    }
    
    func deleteAllMessages(conversationKeyId: Int) -> Bool{
        return ChatStoreDB.shareInstence().deleteAllMessages(conversationKeyId: conversationKeyId)
    }
    
    func updateMsgBody(globalMsgId: String, body: String) -> Bool{
        return ChatStoreDB.shareInstence().updateMsgBody(globalMsgId: globalMsgId, body: body)
    }
    
    func updateConversationBody(keyId: Int, body: String) -> Bool{
        return ChatStoreDB.shareInstence().updateConversationBody(keyId: keyId, body: body)
    }
    
    func setConversationDraft(keyId: Int, draft: String) -> Bool{
        return ChatStoreDB.shareInstence().setConversationDraft(keyId: keyId, draft: draft)
    }
    
    func setConversationMute(keyId: Int, mute: Int) -> Bool{
        return ChatStoreDB.shareInstence().setConversationMute(keyId: keyId, mute: mute)
    }
    func setConversationTopup(keyId: Int, topUp: Int) -> Bool{
        return ChatStoreDB.shareInstence().setConversationTopup(keyId: keyId, topUp: topUp)
    }
    
    func updateMsgStatus(globalMsgId: String, status: Int) -> Bool{
        return ChatStoreDB.shareInstence().updateMsgStatus(globalMsgId: globalMsgId, status: status,timestamp: "")
    }
    
    public func sendCustomMessage(chatId:String,jsonData:String,conversationType:Int){
        let uuid = UUID().uuidString
        let createLocalMsg = ChatStoreDB.shareInstence().createNewMsg(chatId: chatId, from: userId, to: chatId, globalMsgId: uuid, jsonData: jsonData, convsationType: conversationType, errorInfo: "")
        if(createLocalMsg){
            sendingCustomMessage(chatId: chatId, jsonData: jsonData, conversationType: conversationType,globalMsgId: uuid)
            
        }
        
    }
    
    public func sendCustomBroadcast(chatId:String,jsonData:String,conversationType:Int){
        let globalMsgId = UUID().uuidString
        var session:String?
        var mechanism:String?
        var receiver = chatId
        if chatId.contains("[private]") {
            receiver = chatId.replacingOccurrences(of: "[private]", with: "");
            session="[private]"
        }
        var body = jsonData
        var recipient = JID(receiver+"_uc@"+domain);
        if(conversationType == ConversationType.GROUP_CHAT.rawValue){
            recipient=JID(chatId+"@conference."+domain)
            let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
            let chat = messageModule.createChat(with: recipient);
            print("Sending muc message to", recipient, ".."+chatId);
            _ = messageModule.sendBroadcast(in: chat!, body: body,type: StanzaType.groupchat,uuid: globalMsgId);
        }else{
            let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
            let chat = messageModule.createChat(with: recipient);
            print("Sending message to", recipient, ".."+chatId);
            _ = messageModule.sendBroadcast(in: chat!, body: body,mechanism: mechanism,session: session,uuid:globalMsgId);
        }
        
    }
    
    public func resendCustomMessage(globalMsgId:String,jsonData:String,conversationType:Int){
        if updateMsgStatus(globalMsgId: globalMsgId, status: MessageStatus.STATUS_IN_PROGRESS.rawValue) {
            let message = getMessageByKeyIdOrGlobalId(keyId: -1, globalMsgId: globalMsgId)
            if(message != nil){
                sendingCustomMessage(chatId: message!["convsationId"] as! String, jsonData: jsonData, conversationType: conversationType,globalMsgId: message!["messageId"] as! String)
            }
        }
        
        
    }
    
    private func sendingCustomMessage( chatId:String,jsonData:String,conversationType:Int,globalMsgId:String){
        var session:String?
        var mechanism:String?
        var receiver = chatId
        if chatId.contains("[private]") {
            receiver = chatId.replacingOccurrences(of: "[private]", with: "");
            session="[private]"
        }
        var body = jsonData
        var recipient = JID(receiver+"_uc@"+domain);
        if(conversationType == ConversationType.GROUP_CHAT.rawValue){
            recipient=JID(chatId+"@conference."+domain)
            let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
            let chat = messageModule.createChat(with: recipient);
            print("Sending muc message to", recipient, ".."+chatId);
            _ = messageModule.sendMessage(in: chat!, body: body,type: StanzaType.groupchat,uuid: globalMsgId);
        }else{
            let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
            let chat = messageModule.createChat(with: recipient);
            print("Sending message to", recipient, ".."+chatId);
            if(encrypt){
                mechanism = "encrypt"
                body = messageEncryptHelper.encrypt(userId,chatId,jsonData);
            }
            _ = messageModule.sendMessage(in: chat!, body: body,mechanism: mechanism,session: session,uuid:globalMsgId);
        }
    }
    
    func getMessageByKeyIdOrGlobalId(keyId:Int,globalMsgId:String) -> NSDictionary?{
        
        return ChatStoreDB.shareInstence().getMessageBykeyIdOrGlobalId(keyId: keyId, globalMsgId: globalMsgId)
    }
    
    func getConversationByKeyIdOrGlobalId(keyId:Int,chatId:String) -> NSDictionary?{
        
        return ChatStoreDB.shareInstence().getConversationByKeyIdOrGlobalId(keyId: keyId, chatId: chatId)
    }
    func createConversationById(chatId:String,convsationType:Int,title:String) -> Bool {
        return ChatStoreDB.shareInstence().createConversationById(chatId: chatId, convsationType: convsationType, title: title)
    }
    
    func  getMessages(conversationKeyId:Int,msgKeyId:Int,count:Int,prevOrNext:Bool) -> Array<NSDictionary>{
        return ChatStoreDB.shareInstence().getMessages(conversationKeyId: conversationKeyId, msgKeyId: msgKeyId, count: count, prevOrNext: prevOrNext)
    }
    func  getAllConversations() -> Array<NSDictionary>{
        return ChatStoreDB.shareInstence().getAllConversations()
    }
    
    public func quit(){
        ChatStoreDB.shareInstence().closeDB()
        self.userId = "";
        self.domain="";
    }
    
    func joinGroup(chatId:String){
        let mucModule: MucModule = client.modulesManager.getModule(MucModule.ID)!;
        _ = mucModule.join(roomName: chatId, mucServer: "conference."+domain, nickname: userId+"_"+resource);
    }
    
    func checkGroupMember(chatId:String){
        
        let iq = Iq();
        iq.id = UUID().uuidString
        iq.to  =  JID(chatId+"@conference."+domain);
        iq.type = StanzaType.get;
        let query = Element(name: "query", xmlns: "http://jabber.org/protocol/muc#user");
        let item = Element(name: "item");
        item.setAttribute("affiliation", value: "member")
        query.addChild(item)
        iq.addChild(query);
        client.context.writer?.write(iq, timeout: 10, onSuccess: {(response) in
            // response received with type equal `result`
            let iqStanza = response
           
            print("checkGroupMember:\(response)")
            
        }, onError: {(response, errorCondition) in
            // received response with type equal `error`
            print("\(response),\(errorCondition)")
        }, onTimeout: {
            // no response was received in specified time
        });
    }
    
    //read ,delivered
    func sendMsgAck(status:String) {
       //<message xml:lang='*' to='zq68dcd47436c141ee817aa9d32f4f03cc_uc@ul/call' from='zq5ad56d5f981e44a58d7c48ac0bcc564e_uc@ul/call' type='chat'>
        // <x xmlns='jabber:x:event'>
        // <read/>
        // <msgid>63efe617-01dc-4236-a202-9ff06dbe4a97</msgid>
        // <timestamp/>
        // </x>
        // </message>
    }
    
    func createGroup(chatId:String)  {
//       " <iq type=\"set\" to=\"" + chatId + "@conference." + SERVER_NAME + "\" id=\"" + uuid + "\" xmlns:cli=\"jabber:client\">\n" +
//       "    \t<query xmlns=\"http://jabber.org/protocol/muc#owner\">\n" +
//       "    \t<x xmlns=\"jabber:x:data\" type=\"submit\">\n" +
//       "    \t<field var=\"FORM_TYPE\">\n" +
//       "    \t<value>http://jabber.org/protocol/muc#roomconfig</value>\n" +
//       "    \t</field>\n" +
//       "    \t<field var=\"muc#roomconfig_roomname\">\n" +
//       "    \t<value>" + roomName + "</value>\n" +
//       "    \t</field>\n" +
//       "    \t<field var=\"muc#roomconfig_persistentroom\">\n" +
//       "    \t<value>1</value>\n" +
//       "    \t</field>\n" +
//       "    \t</x>\n" +
//       "    \t</query>\n" +
//       "    \t</iq>";
    }
    
    
    func inviteToGroup(chatId:String, memberId:String){
        let inviteMsg = Message();
        inviteMsg.to  =  JID(chatId+"@conference."+domain);
        inviteMsg.from = JID(userId+"_uc@"+domain+"/"+resource);
        inviteMsg.type = StanzaType.normal;
        inviteMsg.setAttribute("type", value: "normal")
        inviteMsg.setAttribute("xmlns", value: "jabber:client")
        let x = Element(name: "x", xmlns: "http://jabber.org/protocol/muc#user");
        let invite = Element(name: "invite");
        invite.setAttribute("to", value: memberId+"_uc@"+domain+"/"+resource)
        let reason = Element(name: "reason", cdata:"invite");
        invite.addChild(reason)
        x.addChild(invite)
        inviteMsg.addChild(x);
        client.context.writer?.write(inviteMsg, timeout: 10, onSuccess: {(response) in
            // response received with type equal `result`
            print("inviteToGroup:\(response)")
            
        }, onError: {(response, errorCondition) in
            // received response with type equal `error`
            print("\(response),\(errorCondition)")
        }, onTimeout: {
            // no response was received in specified time
        });
    }
    
    func kickGroupMember(chatId:String, memberId:String){
    
        let iq = Iq();
        iq.id = UUID().uuidString
        iq.to  =  JID(chatId+"@conference."+domain);
        iq.type = StanzaType.set;
        let query = Element(name: "query", xmlns: "http://jabber.org/protocol/muc#admin");
        query.setAttribute("kick", value: "true")
        let item = Element(name: "item");
        item.setAttribute("jid", value: "\(memberId)_uc@\(domain)/"+resource)
        item.setAttribute("role", value: "none")
        let reason = Element(name: "reason");
        reason.value="LeaveMuc"
        item.addChild(reason)
        query.addChild(item)
        iq.addChild(query);
        client.context.writer?.write(iq, timeout: 10, onSuccess: {(response) in
            // response received with type equal `result`
            print("kickGroupMember:\(response)")
            
        }, onError: {(response, errorCondition) in
            // received response with type equal `error`
            print("\(response),\(errorCondition)")
        }, onTimeout: {
            // no response was received in specified time
        });
    }
    
    public func relogin(){
        if(true){//sdk inited
            var loginData = Dictionary<String, String>()
            loginData["status"] = "connecting"
            ChatStoreDB.shareInstence().postNotifition(actName: "LoginStatusChangedNotify",data:loginData as NSDictionary)
            client.login();
        }else{
            print("im sdk初始化失败，login failed");
        }
    }
    public func login(userId:String,token:String,imHost:String,imPort:Int,domain:String) -> Bool {
        
        
        ChatStoreDB.shareInstence().openDB(_userId: userId);
        
        self.userId = userId;
        self.domain = domain;
        let jid = BareJID(userId+"_uc@"+domain);
        client.connectionConfiguration.setServerHost(imHost);
        client.connectionConfiguration.setServerPort(imPort);
        client.connectionConfiguration.setUserJID(jid);
        client.sessionObject.setUserProperty(SessionObject.RESOURCE, value: resource)
        client.connectionConfiguration.setUserPassword(token);
        // create and register event handler
        class EventBusHandler: EventHandler {
            var _chatModel:ChatModel;
            init(chatModel:ChatModel) {
                _chatModel = chatModel;
            }
            func messageReceived(_ mr: MessageModule.MessageReceivedEvent) {
                print("Received signle new message from", mr.message.from, "with text", mr.message.body);
                let message = mr.message!
                if(message.type == StanzaType.error){
                    
                }else if(message.broadcast != nil){
                    print("Received signle new message from", mr.message.from, "with broadcast", mr.message.broadcast);
                    let broadcast = message.broadcast!
                    var session = message.session
                    if  session == nil {
                        session = ""
                    }
                    let from = (message.from!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                    let chatId = from+session!
                    var broadcastData = Dictionary<String, String>()
                    broadcastData["chatId"] = chatId
                    broadcastData["broadcast"] = broadcast
                    ChatStoreDB.shareInstence().postNotifition(actName: "BroadcastChangedNotify",data:broadcastData as NSDictionary)
                }else{
                    if((message.body) != nil && message.type == StanzaType.chat){
                        print("Received signle new message from", mr.message.from, "with text", mr.message.body);
                        let from = (message.from!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                        let to = (message.to!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                        storeMsg(message: message, from: from, to: to, conversationType: ConversationType.SINGLE_CHAT.rawValue)
                    }
                }
                
            }
            func storeMsg(message:TigaseSwift.Message ,from:String,to:String, conversationType:Int) {
                var session = message.session
                if  session == nil {
                    session = ""
                }
                var body = message.body ?? "";
                if message.mechanism != nil {
                    body = _chatModel.messageEncryptHelper.decrypt(_chatModel.userId, message.body!)
                }
                
                if(body.isEmpty){
                    return
                }
                ChatStoreDB.shareInstence().createNewMsg(chatId: from+session!, from: from, to: to, globalMsgId: message.id!,  jsonData: body, convsationType: conversationType, errorInfo: "")
            }
            
            func messageMucReceived(_ mr: MucModule.MessageReceivedEvent) {
                print("Received group new message from", mr.message.from, "with text", mr.message.body);
                let message = mr.message!
                if(message.type == StanzaType.error){
                    
                }else{
                    if((message.body) != nil && message.type == StanzaType.groupchat){
                        let from = (message.from!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                        let to = (message.to!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                        storeMsg(message: message, from: from, to: to, conversationType: ConversationType.GROUP_CHAT.rawValue)
                    }
                }
            }
            func mucRoomJoined(_ event: MucModule.YouJoinedEvent) {
                
            }
            
            /// Called when session is established
            func sessionEstablished() {
                print("Now we are connected to server and session is ready..");
                var loginData = Dictionary<String, String>()
                loginData["status"] = "connected"
                ChatStoreDB.shareInstence().postNotifition(actName: "LoginStatusChangedNotify",data:loginData as NSDictionary)
                let presenceModule: PresenceModule = _chatModel.client.modulesManager.getModule(PresenceModule.ID)!;
                print("Setting presence to Online...");
                presenceModule.setPresence(show: Presence.Show.online, status: "Online", priority: 0);
                
                let iq = Iq();
                iq.id = UUID().uuidString
                iq.from = JID(_chatModel.userId+"_uc@"+_chatModel.domain+"/"+_chatModel.resource)
                iq.to  =  JID("conference."+_chatModel.domain);
                iq.type = StanzaType.get;
                let query = Element(name: "query", xmlns: DiscoveryModule.ITEMS_XMLNS);
                iq.addChild(query);
                _chatModel.client.context.writer?.write(iq, timeout: 10, onSuccess: {(response) in
                    // response received with type equal `result`
                    print("\(response)")
                     
                    
                }, onError: {(response, errorCondition) in
                    // received response with type equal `error`
                    print("\(response),\(errorCondition)")
                }, onTimeout: {
                    // no response was received in specified time
                });
                
            }
            
            
            func handle(event: Event) {
                print("event bus handler got event = ", event);
                switch event {
                case is SessionEstablishmentModule.SessionEstablishmentSuccessEvent:
                    print("successfully connected to server and authenticated!");
                    sessionEstablished();
                case is SocketConnector.DisconnectedEvent:
                    print("Client is disconnected.");
                    var loginData = Dictionary<String, String>()
                    loginData["status"] = "connected"
                    ChatStoreDB.shareInstence().postNotifition(actName: "LoginStatusChangedNotify",data:loginData as NSDictionary)
                case is RosterModule.ItemUpdatedEvent:
                    print("roster item updated");
                case is PresenceModule.ContactPresenceChanged:
                    print("received presence change event");
                case is MessageModule.ChatCreatedEvent:
                    print("chat was created");
                case let mr as MessageModule.MessageReceivedEvent:
                    print("received message");
                    messageReceived(mr);
                case let mucr as MucModule.MessageReceivedEvent:
                    print("received muc message");
                    messageMucReceived(mucr);
                case let mucr as MucModule.YouJoinedEvent:
                    mucRoomJoined(mucr);
                default:
                    // here will enter other events if this handler will be registered for any other events
                    break;
                }
            }
        }
        
        let eventHandler = EventBusHandler(chatModel: self);
        client.eventBus.register(handler: eventHandler, for: SessionEstablishmentModule.SessionEstablishmentSuccessEvent.TYPE, RosterModule.ItemUpdatedEvent.TYPE, PresenceModule.ContactPresenceChanged.TYPE, MessageModule.MessageReceivedEvent.TYPE, MessageModule.ChatCreatedEvent.TYPE,MucModule.YouJoinedEvent.TYPE, MucModule.MessageReceivedEvent.TYPE, MucModule.OccupantComesEvent.TYPE, MucModule.OccupantLeavedEvent.TYPE, MucModule.OccupantChangedPresenceEvent.TYPE,SocketConnector.DisconnectedEvent.TYPE);
        print("Notifying event but that we are interested in some of MucModule events");
        
        print("Connecting to server..")
        client.modulesManager.register(AuthModule());
        client.modulesManager.register(StreamFeaturesModule());
        client.modulesManager.register(SaslModule());
        client.modulesManager.register(ResourceBinderModule());
        client.modulesManager.register(SessionEstablishmentModule());
        
        print("Registering module for handling presences..");
        client.modulesManager.register(PresenceModule());
        print("Registering module for handling messages..");
        client.modulesManager.register(MessageModule());
        print("Registering module for handling MUC...");
        client.modulesManager.register(MucModule());
        print("Started async processing..");
        relogin();
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    
    
    
}

