//
//  AZDownloadInfoCell.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 25/07/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

class AZDownloadInfoCell: UITableViewCell {

    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var totalSizeLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var remianingTimeLbl: UILabel!
    @IBOutlet weak var downloadedLbl: UILabel!
    @IBOutlet weak var downloadStatusLbl: UILabel!
    @IBOutlet weak var downloadPercentLbl: UILabel!
    @IBOutlet weak var downloadPercentPVw: UIProgressView!
}
