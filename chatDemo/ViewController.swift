//
//  ViewController.swift
//  chatDemo
//
//  Created by mac on 2020/1/6.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import TigaseSwift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var client = XMPPClient();
     
                let jid = BareJID("sender@domain.com");
                client.connectionConfiguration.setUserJID(jid);
                client.connectionConfiguration.setUserPassword("Pa$$w0rd");
               print("Connecting to server..")
               client.login();
               print("Started async processing..");
    }

//    func registerModules() {
//        print("Registering modules required for authentication and session establishment");
//        _ = client.modulesManager.register(AuthModule());
//        _ = client.modulesManager.register(StreamFeaturesModule());
//        _ = client.modulesManager.register(SaslModule());
//        _ = client.modulesManager.register(ResourceBinderModule());
//        _ = client.modulesManager.register(SessionEstablishmentModule());
//
//        print("Registering module for handling presences..");
//        _ = client.modulesManager.register(PresenceModule());
//        print("Registering module for handling messages..");
//        _ = client.modulesManager.register(MessageModule());
//    }

//    func setCredentials(userJID: String, password: String) {
//        let jid = BareJID(userJID);
//        client.connectionConfiguration.setUserJID(jid);
//        client.connectionConfiguration.setUserPassword(password);
//    }
//
//    /// Processing received events
//    func handle(event: Event) {
//        switch (event) {
//        case is SessionEstablishmentModule.SessionEstablishmentSuccessEvent:
//            sessionEstablished();
//        case is SocketConnector.DisconnectedEvent:
//            print("Client is disconnected.");
//        case let cpc as PresenceModule.ContactPresenceChanged:
//            contactPresenceChanged(cpc);
//        case let mr as MessageModule.MessageReceivedEvent:
//            messageReceived(mr);
//        default:
//            print("unsupported event", event);
//        }
//    }
//
//    /// Called when session is established
//    func sessionEstablished() {
//        print("Now we are connected to server and session is ready..");
//
//        let presenceModule: PresenceModule = client.modulesManager.getModule(PresenceModule.ID)!;
//        print("Setting presence to DND...");
//        presenceModule.setPresence(show: Presence.Show.dnd, status: "Do not distrub me!", priority: 2);
//    }
//
//    func contactPresenceChanged(_ cpc: PresenceModule.ContactPresenceChanged) {
//        print("We got notified that", cpc.presence.from, "changed presence to", cpc.presence.show);
//    }
//
//    func messageReceived(_ mr: MessageModule.MessageReceivedEvent) {
//        print("Received new message from", mr.message.from, "with text", mr.message.body);
//
//        let messageModule: MessageModule = client.modulesManager.getModule(MessageModule.ID)!;
//        print("Creating chat instance if it was not received..");
//        let chat = mr.chat ?? messageModule.createChat(with: mr.message.from!);
//        print("Sending response..");
//        _ = messageModule.sendMessage(in: chat!, body: "Message in response to: " + (mr.message.body ?? ""));
//    }

}

