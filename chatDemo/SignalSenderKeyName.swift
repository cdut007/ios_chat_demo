//
//  SignalSenderKeyName.swift
//  SignalProtocolSwift-iOS
//
//  Created by User on 18.11.17.
//

import Foundation

/**
 * A representation of a (group + sender + device) tuple
 */
public struct SignalSenderKeyName {

    /// The group identifier (such as the name)
    let groupId: String

    /// The contact
    let sender: SignalAddress

    /**
     Create a new `SignalSenderKeyName`
     - parameter groupId: The group identifier (such as the name)
     - parameter sender: The contact
     */
    public init(groupId: String, sender: SignalAddress) {
        self.groupId = groupId
        self.sender = sender
    }
}

extension SignalSenderKeyName: Equatable {
    
    /**
     Compare two `SignalSenderKeyName`. Two `SignalSenderKeyName` objects are
     equal if their identifier and sender are equal.
     - parameter lhs: The first address
     - parameter rhs: The second address
     - returns: `True` if the addresses are equal.
     */
    public static func ==(lhs: SignalSenderKeyName, rhs: SignalSenderKeyName) -> Bool {
        return lhs.groupId == rhs.groupId && lhs.sender == rhs.sender
    }
}

extension SignalSenderKeyName: Hashable { }

extension SignalSenderKeyName: CustomStringConvertible {

    /**
     A String representation of the sender key name.
     */
    public var description: String {
        return "SignalSenderKeyName(group: \(groupId), id: \(sender.identifier), device: \(sender.deviceId))"
    }
}
