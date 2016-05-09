//
//  AZSongTableViewCell.swift
//  Amuzzin_iOS
//
//  Created by C!T! on 16/04/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZSongTableViewCell: AZCommonTableViewCell {

    @IBOutlet weak var imgVw: UIImageView!
    
    @IBOutlet weak var dragImgVw: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var albumLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    
    @IBOutlet weak var addAction: UIButton!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.clipsToBounds = true

    }

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    
    
    
}
