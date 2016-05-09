//
//  AZPlaylistTVCell.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 04/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZPlaylistTVCell: UITableViewCell {

    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var playlisttitleLbl: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
