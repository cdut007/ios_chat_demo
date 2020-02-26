//
//  MessageEncrptHelper.swift
//  chatDemo
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 mac. All rights reserved.
//


import SignalProtocol


class MessageEncryptHelper{
    
    
     private func initBasicSessionV3() {
               /* Create Alice's session record */
               let aliceSessionRecord = SessionRecord(state: nil)

               /* Create Bob's session record */
               let bobSessionRecord = SessionRecord(state: nil)

               initializeSessionsV3(aliceSessionRecord.state, bobSessionRecord.state)
               runInteraction(aliceSessionRecord, bobSessionRecord)

           }
        
        private func initializeSessionsV3(_ aliceState: SessionState, _ bobstate: SessionState) {
            /* Generate Alice's identity key */
            /* Generate Alice's base key */
            /* Generate Alice's ephemeral key */
            /* Generate Bob's identity key */
            /* Generate Bob's base key */
            /* Generate Bob's pre-key */
            guard let aliceIdentityKey = try? KeyPair(),
                let aliceBaseKey = try? KeyPair(),
                let bobIdentityKey = try? KeyPair(),
                let bobBaseKey = try? KeyPair() else {
                  //  XCTFail("Could not generate keys")
                    return
            }

            do {
                try aliceState.aliceInitialize(
                    ourIdentityKey: aliceIdentityKey,
                    ourBaseKey: aliceBaseKey,
                    theirIdentityKey: bobIdentityKey.publicKey,
                    theirSignedPreKey: bobBaseKey.publicKey,
                    theirOneTimePreKey: nil,
                    theirRatchetKey: bobBaseKey.publicKey)

                try bobstate.bobInitialize(
                    ourIdentityKey: bobIdentityKey,
                    ourSignedPreKey: bobBaseKey,
                    ourOneTimePreKey: nil,
                    ourRatchetKey: bobBaseKey,
                    theirIdentityKey: aliceIdentityKey.publicKey,
                    theirBaseKey: aliceBaseKey.publicKey)

            } catch {
              //  XCTFail("Could not initialize sessions")
                return
            }
        }
      
        private func decrypt(_ userId:String,_ encryptMsg:String) ->String{
            let index = encryptMsg.range(of: ".")!.lowerBound;
            let decode_msg_content  = String(encryptMsg[..<index]);
            let pos = index.utf16Offset(in: encryptMsg)+2;
            let decode_session_key  = String(encryptMsg.suffix(encryptMsg.count-pos));
            
            /* Create Alice's session record */
            let aliceSessionRecord = SessionRecord(state: nil)
             /* Create Bob's session record */
             var bobSessionRecord = SessionRecord(state: nil)

             initializeSessionsV3(aliceSessionRecord.state, bobSessionRecord.state)
           
            do {
                let decode_session_keyData = Data(base64Encoded: decode_session_key)!
                  bobSessionRecord = try SessionRecord(from:decode_session_keyData);
                       
                        let aliceAddress = SignalAddress(identifier: userId, deviceId: 1)
                        /* Create the test data stores */
                        let bobStore = CustomKeyStore()
                       /* Store the two sessions in their data stores */
                var a2:Data;
                try  a2 = bobSessionRecord.protoData();
                try bobStore.sessionStore.store(session: a2 , for: aliceAddress)
                /* Create two session cipher instances */
                    let bobCipher = SessionCipher(store: bobStore, remoteAddress: aliceAddress)
                       
                       /* Have Bob decrypt the test message */
                       /* Create a signal_message from the ciphertext */
                       let aliceEncryptMessageData = Data(base64Encoded: decode_msg_content)!
                       let message =  try SignalMessage(from: aliceEncryptMessageData)

                              /* Decrypt the message */
                       let decrypted =  try bobCipher.decrypt(signalMessage: message)

                         
                       var decryptedString = String(data: decrypted, encoding: String.Encoding.utf8)!;
                return decryptedString;
            } catch {
                switch error {
               case let e1 as SignalError:
                print("Could decrpty  sessions:"+e1.message!)
                default:
                    print("Could decrpty  sessions 99")
                }
                
                return ""
            }
           
           

        }
        
        private func encrypt(_ senderId:String,_ receiverId:String, _ content:String) -> String{
              
                
                /* Create Alice's session record */
                let aliceSessionRecord = SessionRecord(state: nil)

                 /* Create Bob's session record */
                 var bobSessionRecord = SessionRecord(state: nil)

                 initializeSessionsV3(aliceSessionRecord.state, bobSessionRecord.state)
              
               /* Create the test data stores */
                      let aliceStore = CustomKeyStore()
                      let bobStore = CustomKeyStore()
            let aliceAddress = SignalAddress(identifier: senderId, deviceId: 1)

            let bobAddress = SignalAddress(identifier: receiverId, deviceId: 1)
            /* Store the two sessions in their data stores */
                   do {
                       var a1:Data;
                       var a2:Data;
                       try  a1 = aliceSessionRecord.protoData();
                       try  a2 = bobSessionRecord.protoData();
                       try aliceStore.sessionStore.store(session: a1, for: aliceAddress)
                       try bobStore.sessionStore.store(session: a2 , for: bobAddress)
                       let aliceCipher = SessionCipher(store: aliceStore, remoteAddress: aliceAddress)
                       let aliceMessage = try aliceCipher.encrypt(content.data(using: .utf8)!)
                       let encryptBase64Data = aliceMessage.data.base64EncodedString()
    //                 let bytes = [UInt8](aliceMessage.data)
    //                 let intArray = bytes.map { Int8(bitPattern: $0) }
                    
                     let bobSessionRecordBase64Data = try bobSessionRecord.protoData().base64EncodedString()
                     let random_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                      //let pos = (int) ((Math.random() * random_chars.length()) % random_chars.length());
                      let flag = "q";
                      let encryptMsg = encryptBase64Data + "." + flag + bobSessionRecordBase64Data;
                    return encryptMsg
                   } catch {
                     //  XCTFail("Could not store sessions")
                       return ""
                   }

              
                  
            
            }

        private func runInteraction(_ aliceRecord: SessionRecord, _ bobRecord: SessionRecord) {


            let aliceAddress = SignalAddress(identifier: "+14159999999", deviceId: 1)

            let bobAddress = SignalAddress(identifier: "+14158888888", deviceId: 1)
            /* Create the test data stores */
            let aliceStore = CustomKeyStore()
            let bobStore = CustomKeyStore()

            /* Store the two sessions in their data stores */
            do {
                var a1:Data;
                var a2:Data;
                try  a1 = aliceRecord.protoData();
                try  a2 = bobRecord.protoData();
                try aliceStore.sessionStore.store(session: a1, for: bobAddress)
                try bobStore.sessionStore.store(session: a2 , for: aliceAddress)
            } catch {
              //  XCTFail("Could not store sessions")
                return
            }

            /* Create two session cipher instances */
            let aliceCipher = SessionCipher(store: aliceStore, remoteAddress: bobAddress)
            let bobCipher = SessionCipher(store: bobStore, remoteAddress: aliceAddress)

             /* Encrypt a test message from Alice */
            let alicePlaintext = "This is a plaintext message.".data(using: .utf8)!
            guard let aliceMessage = try? aliceCipher.encrypt(alicePlaintext) else {
               // XCTFail("Could not encrypt message from Alice")
                return
            }

            /* Have Bob decrypt the test message */
            do {
                try decryptAndCompareMessages(
                    cipher: bobCipher,
                    ciphertext: aliceMessage.data,
                    plaintext: alicePlaintext)
            } catch {
              //  XCTFail("Could not decrypt message from Alice")
                return
            }

            /* Encrypt a reply from Bob */
            let bobReply = "This is a message from Bob.".data(using: .utf8)!
            guard let replyMessage = try? bobCipher.encrypt(bobReply) else {
               // XCTFail("Could not encrypt reply from Bob")
                return
            }

            /* Have Alice decrypt the reply message */
            do {
                try decryptAndCompareMessages(
                    cipher: aliceCipher,
                    ciphertext: replyMessage.data,
                    plaintext: bobReply)
            } catch {
              //  XCTFail("Could not decrypt reply message from Bob")
                return
            }


        }
        private func decryptAndCompareMessages(cipher: SessionCipher<CustomKeyStore>, ciphertext: Data, plaintext: Data) throws {
            /* Create a signal_message from the ciphertext */
            let message = try SignalMessage(from: ciphertext)

            /* Decrypt the message */
            let decrypted = try cipher.decrypt(signalMessage: message)

            /* Compare the messages */
            if plaintext != decrypted {
                throw SignalError(.invalidMessage, "")
            }
            var decryptedString = String(data: decrypted, encoding: String.Encoding.utf8);
            // decryptedString;
        }
}
