//
//  LeaderboardButton.swift
//  Shape Target
//
//  Created by Trevor Stevenson on 5/9/15.
//  Copyright (c) 2015 NCUnited. All rights reserved.
//

import UIKit

class LeaderboardButton: UIButton {
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        self.layer.cornerRadius = 25.0
        self.clipsToBounds = true
        
        self.backgroundColor = UIColor.black
        
        self.tintColor = UIColor.white
        
        self.titleLabel?.font = UIFont(name: "Verdana", size: 17)
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        
        let path = UIBezierPath(rect: self.frame)
        
        UIColor.black.setFill()
        
        path.fill()
        
    }
    
    
}

