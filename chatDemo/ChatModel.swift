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
    
    
    public func sendCustomMessage(receiverId:String,content:String){
        
        let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
        let recipient = JID(receiverId+"_uc@ul");
        let chat = messageModule.createChat(with: recipient);
        print("Sending message to", recipient, ".."+receiverId);
        _ = messageModule.sendMessage(in: chat!, body: content);
        
    }
    
    public func quit(){
        ChatStoreDB.shareInstence().closeDB()
        self.userId = "";
        self.domain="";
    }
    
    public func relogin(){
        if(true){//sdk inited
            client.login();
        }else{
            print("im sdk初始化失败，login failed");
        }
    }
    public func login(userId:String,token:String,imHost:String,imPort:Int,domain:String) -> Bool {
        
        
        ChatStoreDB.shareInstence().openDB(_userId: userId);
        
        self.userId = userId;
        let jid = BareJID(userId+"_uc@"+domain);
        client.connectionConfiguration.setServerHost(imHost);
        client.connectionConfiguration.setServerPort(imPort);
        client.connectionConfiguration.setUserJID(jid);
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
                if((message.body) != nil){
                    let from = (message.from!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                    let to = (message.to!.bareJid.localPart!).replacingOccurrences(of: "_uc", with: "");
                    ChatStoreDB.shareInstence().createNewMsg(chatId: from, from: from, to: to, globalMsgId: message.id!,  jsonData: message.body!, convsationType: ConversationType.SINGLE_CHAT.rawValue, errorInfo: "")
                }
                
                //                let text = "test";
                //                let content = "{\"messageType\":\"TextMessage\",\"messageTypeValue\":1,\"data\":{\"content\":\""+text+"\"},\"messageEncrypt\":\"true\",\"peerInfo\":{\"userName\":\"\",\"mobile\":\"\",\"nickName\":\"\"}}";
                // _chatModel.sendCustomMessage(receiverId:"zq30695873350b443bbc992c691e525201", content:content);
            }
            func messageMucReceived(_ mr: MucModule.MessageReceivedEvent) {
                print("Received group new message from", mr.message.from, "with text", mr.message.body);
            }
            func handle(event: Event) {
                print("event bus handler got event = ", event);
                switch event {
                case is SessionEstablishmentModule.SessionEstablishmentSuccessEvent:
                    print("successfully connected to server and authenticated!");
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
                default:
                    // here will enter other events if this handler will be registered for any other events
                    break;
                }
            }
        }
        
        let eventHandler = EventBusHandler(chatModel: self);
        client.eventBus.register(handler: eventHandler, for: SessionEstablishmentModule.SessionEstablishmentSuccessEvent.TYPE, RosterModule.ItemUpdatedEvent.TYPE, PresenceModule.ContactPresenceChanged.TYPE, MessageModule.MessageReceivedEvent.TYPE, MessageModule.ChatCreatedEvent.TYPE,MucModule.YouJoinedEvent.TYPE, MucModule.MessageReceivedEvent.TYPE, MucModule.OccupantComesEvent.TYPE, MucModule.OccupantLeavedEvent.TYPE, MucModule.OccupantChangedPresenceEvent.TYPE);
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

