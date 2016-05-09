//
//  AZAlbumTableViewCell.swift
//  Amuzzin_iOS
//
//  Created by C!T! on 16/04/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZAlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var imgAlbumVw: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var totalSongs: UILabel!
    @IBOutlet weak var totMinslbl: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        //self.layer.borderColor = UIColor.whiteColor().CGColor
        //self.layer.borderWidth = 4.0
        self.clipsToBounds = true
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
