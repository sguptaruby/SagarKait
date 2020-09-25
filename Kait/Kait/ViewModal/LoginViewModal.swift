//
//  LoginViewModal.swift
//  Kait
//
//  Created by Apple on 08/04/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation

class LoginViewModal {
    
    var email: String!
    var password: String!
    var device_token: String!
    
    func loginApi(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.login(id: email, password: password, device_token: device_token)) { (data, code, error) in
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
    
    func tokenRefreshApi(completion: @escaping((Int,JSONDictionary?,APIError?) -> ())) {
        APIController.makeRequestReturnJSON(.tokenRefresh(token: AppManager.share.user.userToken)) { (data, code, error) in
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
    
}
