//
//  AZPlayerSlider.swift
//  Amuzzin_iOS
//
//  Created by 01HW842980 on 25/05/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZPlayerSlider: UISlider
{
   
    
   override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.constructSlider()
        
    }

   required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.constructSlider()
    }
    
    
    func constructSlider()
    {
    self.setThumbImage(UIImage(named: "sliderthumb"), forState: .Normal)
        
    }
    
    //MARK:UI Control events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        return super.continueTrackingWithTouch(touch, withEvent: event)

    }
}
