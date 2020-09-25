//
//  ReciverTableViewCell.swift
//  Kait
//
//  Created by Apple on 26/03/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit

class ReciverTableViewCell: UITableViewCell {
    
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
        
        messageBGView.layer.shadowColor = UIColor.black.cgColor
        messageBGView.layer.shadowOpacity = 1
        messageBGView.layer.shadowOffset = .zero
        messageBGView.layer.shadowRadius = 20
        messageBGView.backgroundColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        maskLayer.path = UIBezierPath(roundedRect: messageBGView.bounds, byRoundingCorners: [.topLeft, .topRight,.bottomLeft], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        messageBGView.layer.mask = maskLayer
        messageBGView.layer.masksToBounds = true
    }
    
}
