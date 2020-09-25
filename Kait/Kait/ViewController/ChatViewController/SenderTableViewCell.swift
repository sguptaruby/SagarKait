//
//  SenderTableViewCell.swift
//  Kait
//
//  Created by Apple on 26/03/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit

class SenderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageview:UIImageView!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblMOM:UILabel!
    @IBOutlet weak var messageBGView:UIView!
    let maskLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //messageBGView.layer.cornerRadius = 20
        //messageBGView.layer.masksToBounds = true
        messageBGView.layer.shadowColor = UIColor.black.cgColor
        messageBGView.layer.shadowOpacity = 1
        messageBGView.layer.shadowOffset = .zero
        messageBGView.layer.shadowRadius = 20
        
    }
    
    override func draw(_ rect: CGRect) {
        maskLayer.path = UIBezierPath(roundedRect: messageBGView.bounds, byRoundingCorners: [.topLeft, .topRight,.bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        messageBGView.layer.mask = maskLayer
        messageBGView.layer.masksToBounds = true
    }
    
    
}
