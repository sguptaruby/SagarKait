//
//  FriendListViewModal.swift
//  Kait
//
//  Created by Apple on 13/04/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation
import UIKit

class FriendListViewModal {
    
    var userID: String!
    
    
    func allApi(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.all(id: userID)) { (data, code, error) in
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
    
    func webChatUsersApi(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.webChatUsers(id: userID)) { (data, code, error) in
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
    
    func assignedToOtherApi(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.assignedToOther(id: userID)) { (data, code, error) in
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
    
    func userOnline(view:UIView,isOnline:String, completion:@escaping(JSONDictionary?,Error?)->Void) {
        
        
        view.showHUD()
        
        //create the url with URL
        let url = URL(string: "\(Constants.API.baseURL)v1/customer/\(AppManager.share.user.restaurantRecordId)/change/active/status")! //change the url
                
        let parameters = [
          [
            "key": "is_start_auto_assignment",
            "value": isOnline,
            "type": "text"
          ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        //var error: Error? = nil
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            } else {
              let paramSrc = param["src"] as! String
                guard let fileData = Data(base64Encoded:paramSrc, options:[]) else {
                    return
                }
              let fileContent = String(data: fileData, encoding: .utf8)!
              body += "; filename=\"\(paramSrc)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        //create the session object
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("JWT \(AppManager.share.user.userToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = postData
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                view.hideHUD()
            }
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    //print(json)
                    completion(json,nil)
                }
            } catch let error {
                completion(nil,error)
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}
