//
//  AppManager.swift
//  Kait
//
//  Created by Apple on 08/04/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation
import UIKit

class AppManager {
    
    static let share = AppManager()
    public let Style = DefaultStyle.self
    
    private init() {
        
    }
    var user: User!
    var arrChat = [String]()
    var selectedIndex  = 0
}


public enum DefaultStyle {

    public enum Colors {

        public static let label: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return .black
            }
        }()
    }
}
