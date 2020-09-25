//
//  SocketChatModal.swift
//  Kait
//
//  Created by Apple on 18/06/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation

struct SocketChatModal:Codable {
    let message: Message
    
}

struct Message:Codable {    
    let type: String
}

