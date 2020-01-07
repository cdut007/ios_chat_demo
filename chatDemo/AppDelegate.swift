//
//  AppDelegate.swift
//  chatDemo
//
//  Created by mac on 2020/1/6.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import TigaseSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var client = XMPPClient();
        // register modules
                       let jid = BareJID("zqc1f7b4b49d4641e8b76ae3a59cd25a0f_uc@ul");
        client.connectionConfiguration.setServerHost("hfuc.aitelian.cn");
                       client.connectionConfiguration.setServerPort(5221);
                       client.connectionConfiguration.setUserJID(jid);
                       client.connectionConfiguration.setUserPassword("Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6InpxYzFmN2I0YjQ5ZDQ2NDFlOGI3NmFlM2E1OWNkMjVhMGYiLCJ0eXBlIjoidXNlciIsImV4cCI6MTU3OTU4OTcwMSwiaWF0IjoxNTc4MjkzNzAxfQ.oGpgG8Wpv6BmMqLK5-Xd-_JNA77Fpy6OKBf4zgZcgWM");
   // create and register event handler
   class EventBusHandler: EventHandler {
      init() {
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
          case is MessageModule.MessageReceivedEvent:
              print("received message");
          default:
              // here will enter other events if this handler will be registered for any other events
              break;
          }
      }
   }

   let eventHandler = EventBusHandler();
        client.context.eventBus.register(handler: eventHandler, for: SessionEstablishmentModule.SessionEstablishmentSuccessEvent.TYPE, RosterModule.ItemUpdatedEvent.TYPE, PresenceModule.ContactPresenceChanged.TYPE, MessageModule.MessageReceivedEvent.TYPE, MessageModule.ChatCreatedEvent.TYPE);
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
                      client.login();
                      print("Started async processing..");
        return true
    }

    // MARK: UISceneSession Lifecycle

  


}

