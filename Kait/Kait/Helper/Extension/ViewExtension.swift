//
//  ViewExtension.swift
//  Kait
//
//  Created by Apple on 08/04/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIView {
    
    internal func showHUD() {
        MBProgressHUD.showAdded(to: self, animated: true)
    }
    
    internal func hideHUD() {
        MBProgressHUD.hide(for: self, animated: true)
    }
    
}
