//
//  AZCommonNavController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 11/06/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class AZCommonNavController: UINavigationController,UITextFieldDelegate {

    var searchBarbtn: UIBarButtonItem!
    var searchVwBool:Bool!
    var searchBar:UITextField!
    var searchVwCntrl:AZSearchViewControllerTableViewController?
//    var imageview:UIImageView?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-100, -100.0), forBarMetrics: UIBarMetrics.Default)
        searchVwBool = false
        self.navigationBar.barTintColor = UIColor(red: 208/255, green: 48/255, blue: 55/255, alpha: 1.0)
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSBackgroundColorAttributeName:UIColor.whiteColor()]
        searchBarbtn = UIBarButtonItem(image: UIImage(named: "Search"), style: UIBarButtonItemStyle.Done, target: self, action: "searchButtonClicked:")

        self.setSearchBarButtonItem()

      //  self.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSearchBarButtonItem()
    {
        self.topViewController!.navigationItem.rightBarButtonItem = searchBarbtn

    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
      return  UIStatusBarStyle.LightContent
    }
    
    func searchButtonClicked(sender: AnyObject)
    {
        let senderImage:UIImage = (sender as! UIBarButtonItem).image!
        
        if self.searchVwBool == false
        {
            self.topViewController!.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.clearColor(),NSBackgroundColorAttributeName:UIColor.clearColor()]

            self.searchBar = UITextField(frame: CGRectMake(30, 0, 280, 40))
            self.searchBar.delegate = self
            self.searchBar.backgroundColor = UIColor.clearColor()
            self.searchBar.becomeFirstResponder()
            self.searchBar.textColor = UIColor.whiteColor()
            self.searchBar.placeholder = "Search Music"
                //UIColor(red: 208/255, green: 48/255, blue: 55/255, alpha: 1.0)

            self.navigationBar.addSubview(self.searchBar)
            self.searchVwBool = true

            self.searchVwCntrl = self.storyboard?.instantiateViewControllerWithIdentifier("AZSeachViewController") as? AZSearchViewControllerTableViewController
            self.pushViewController(self.searchVwCntrl!, animated: false)
            self.searchBarbtn.image = UIImage(named: "close")
            setSearchBarButtonItem()

        }
        else
        {
            self.searchBar.text =  ""
            
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let searchTextStr = textField.text! + string
        if string.isEmpty == false
        {
        AZSearchManager.sharedInstance.searchForText(searchTextStr)
        self.searchVwCntrl?.resetView()
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController?
    {
        if searchVwBool == true
        {
            self.topViewController!.navigationItem.setHidesBackButton(false, animated: false)
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSBackgroundColorAttributeName:UIColor.whiteColor()]
            self.searchVwBool = false
            self.searchBarbtn.image = UIImage(named: "Search")
            
            self.searchBar.removeFromSuperview()

        }
        return super.popViewControllerAnimated(animated)
    }

    
    override func showViewController(vc: UIViewController, sender: AnyObject!)
    {
        super.showViewController(vc, sender: sender)
        self.setSearchBarButtonItem()

    }
    
    
}
