


import Moya
//import Result
import Alamofire

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
let APIProvider = MoyaProvider<API>()

enum API {
    
    case login(id:String,password:String,device_token:String)
    case tokenRefresh(token:String)
    case all(id:String)
    case webChatUsers(id:String)
    case assignedToOther(id:String)
    case chatHistory(bot_id:String,user_id:String,type:String)
    case sendMessage(dict:JSONDictionary)
    
}
extension API: TargetType {
    
    public var headers: [String : String]? {
        if Helpers.userToken() == "" {
            return ["Authorization":""]
        }else{
            return ["Authorization":"JWT \(Helpers.userToken())"]
        }
    }
    
    var baseURL : URL { return URL(string: Constants.API.baseURL)! }
    
    var path: String {
        switch self {
        case .login:
            return "v1/customer/login/"
        case .tokenRefresh(_):
            return "token/refresh/"
        case .all(let id):
            return "hil/get/active-conversations?bot_ids=\(id)"
        case .webChatUsers(let id):
            return "hil/get/active-conversations?bot_ids=WEBCHAT-\(id)"
        case .assignedToOther:
            return "token/refresh/"
        case .chatHistory(let bot_id, let user_id, let type):
            return "hil/get/user-conversations?channel=\(type)&bot_id=\(bot_id)&user_id=\(user_id)"
        case .sendMessage:
            return "v1/customer/send/messsage/"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .login,.webChatUsers,.assignedToOther,.sendMessage :
            return .post
        case .chatHistory,.all:
            return .get
        case .tokenRefresh:
            return .post
        }
    }
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .login(let id, let password, let device_token):
            return .requestParameters(parameters: ["user_name":id,"password":password, "device_token":device_token], encoding: JSONEncoding.default)
        case .tokenRefresh(let token):
            return .requestParameters(parameters: ["token":token], encoding: JSONEncoding.default)
        case .all, .webChatUsers:
            return .requestPlain
        
        case .assignedToOther(let id):
            return .requestParameters(parameters: ["userid":id], encoding: JSONEncoding.default)
        case .chatHistory:
            return .requestPlain
        case .sendMessage(dict: let dict):
            return .requestParameters(parameters: dict, encoding: JSONEncoding.default)
        }
    }
    struct JsonArrayEncoding: Moya.ParameterEncoding {
        public static var `default`: JsonArrayEncoding { return JsonArrayEncoding() }
        public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var req = try urlRequest.asURLRequest()
            let json = try JSONSerialization.data(withJSONObject: parameters!["jsonArray"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
            req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            req.httpBody = json
            return req
        }
    }
}

