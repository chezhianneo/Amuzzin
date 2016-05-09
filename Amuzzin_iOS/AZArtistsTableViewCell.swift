//
//  AZArtistsTableViewCell.swift
//  Amuzzin_iOS
//
//  Created by C!T! on 16/04/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZArtistsTableViewCell: UITableViewCell {

    @IBOutlet weak var artistImgVw: UIImageView!
    @IBOutlet weak var artistTitleLbl: UILabel!
    @IBOutlet weak var artistTypeLbl: UILabel!
    @IBOutlet weak var artistCountLbl: UILabel!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        self.clipsToBounds = true
    }

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
