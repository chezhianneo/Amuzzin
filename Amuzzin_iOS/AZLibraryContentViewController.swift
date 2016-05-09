//
//  AZLibraryContentViewController.swift
//  Amuzzin_iOS
//
//  Created by Sankar Narayanan on 3/31/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit


class AZLibraryContentViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout
{
    var pageIndex:Int?
    var color:UIColor?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = color
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 100
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AZLibColnCell", forIndexPath: indexPath) as! AZColnLibViewCell
        
        return cell as AZColnLibViewCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(170, 240)
        
    }

    
    
    
}
