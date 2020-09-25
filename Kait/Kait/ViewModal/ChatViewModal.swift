//
//  ChatViewModal.swift
//  Kait
//
//  Created by Apple on 24/04/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation

class ChatViewModal {
    
    var bot_id:String!
    var user_id:String!
    var type:String!
    var senc_dict:JSONDictionary!
    
    func getChatHistory(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.chatHistory(bot_id: bot_id, user_id: user_id, type:type)) { (data, code, error) in
            if data != nil {
                //let code = data!["code"] as! Int
                APIController.validateJason("\(code)", completion: { (bool) in
                    if bool {
                        completion(code, data, error)
                    }else{
                        completion(code, data, error)
                    }
                })
            }else{
                completion(code,nil, error)
            }
        }
    }
    
    func sendMessage(completion:@escaping (Int,JSONDictionary?,Error?)->()) {
        APIController.makeRequestReturnJSON(.sendMessage(dict: senc_dict)) { (data, code, error) in
            if data != nil {
                //let code = data!["code"] as! Int
                APIController.validateJason("\(code)", completion: { (bool) in
                    if bool {
                        completion(code, data, error)
                    }else{
                        completion(code, data, error)
                    }
                })
            }else{
                completion(code,nil, error)
            }
        }
    }
    
    
    func unassignConversation(dict:JSONDictionary,completion:@escaping(Int?,JSONDictionary?,Error?)->()) {
        
        guard let url = URL(string: "\(Constants.API.baseURL)v1/customer/unassign/conversation/") else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("JWT \(AppManager.share.user.userToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let jsonData = data {
                    do {
                        let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                        if let dictFromJSON = decoded as? JSONDictionary {
                            completion(1,dictFromJSON,nil)
                        }
                    }catch {
                        completion(0,nil,error)
                        print(error.localizedDescription)
                    }
                }else{
                   completion(0,nil,error)
                }
            }.resume()
        } catch {
            completion(0,nil,error)
            print(error.localizedDescription)
        }
        
    }
    
}
