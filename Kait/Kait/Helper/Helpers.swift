





import Foundation
import Alamofire

struct Helpers {
    
    static func userToken() -> String {
        guard let token = UserDefaults.standard.value(forKey: "Authorization") else {
            return ""
        }
        return token as! String
    }
    
    static func saveUserToken(token:String){
        UserDefaults.standard.set(token, forKey: "Authorization")
        UserDefaults.standard.synchronize()
    }
    
    static func saveUserData(data:JSONDictionary){
        UserDefaults.standard.set(data, forKey: "User")
        UserDefaults.standard.synchronize()
    }
    
    static func getUserData() -> JSONDictionary {
        return UserDefaults.standard.value(forKey: "User") as? JSONDictionary ?? [:]
    }
    
    static func saveDeviceToken(token:String){
           UserDefaults.standard.set(token, forKey: "devicetoken")
           UserDefaults.standard.synchronize()
       }
    
    static func getDeviceToken() -> String {
        return UserDefaults.standard.value(forKey: "devicetoken") as? String ?? ""
    }
    
    static func removeUserToken() {
        UserDefaults.standard.removeObject(forKey: "Authorization")
    }
    
    static func saveUserOnline(isOnline:Bool){
        UserDefaults.standard.set(isOnline, forKey: "isOnline")
        UserDefaults.standard.synchronize()
    }
    
    static func getUserOnline() -> Bool {
        return UserDefaults.standard.value(forKey: "isOnline") as? Bool ?? false
    }
    
    static func validateResponse(_ statusCode: Int) -> Bool {
        if case 200...300 = statusCode {
            return true
        }
        return false
    }
}

//MARK: UIImageView
class RoundImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width/2

    }
    
}

//MARK: UIButton
class RoundCornerButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true

    }
    
}
struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}
