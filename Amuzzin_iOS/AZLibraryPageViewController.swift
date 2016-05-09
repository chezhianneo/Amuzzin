//
//  AZLibraryPageViewController.swift
//  Amuzzin_iOS
//
//  Created by Sankar Narayanan on 3/31/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//

import UIKit

enum AZLibraryType
{
    case Album
    case Song
    case Artist
    case Genre
}

class AZLibraryPageViewController: UIViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate
{
    var pageViewCntl:UIPageViewController?
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var segmentView: UIView!
    var endingIndex:Int
    var startingIndex:Int
    
    override func viewDidAppear(animated: Bool)
    {
        self.title = "Library"
        
    }


    required init(coder aDecoder: NSCoder)
    {
        self.startingIndex = 0
        self.endingIndex = 0
        super.init(coder: aDecoder)!

    }
    
    
    override func viewDidLoad()
    {
       // self.delegate =  self
        
        super.viewDidLoad()
        self.typeSegmentedControl.selectedSegmentIndex = 0
        self.setupPageViewController()
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    
    func setupPageViewController()
    {
        
        pageViewCntl = self.storyboard?.instantiateViewControllerWithIdentifier("LibraryPageController") as? UIPageViewController
        self.addChildViewController(pageViewCntl!)
        
        pageViewCntl?.delegate = self
        pageViewCntl?.dataSource = self
        self.pageViewCntl?.view.frame = CGRect(x: 0, y:self.segmentView.frame.origin.y + self.segmentView.bounds.size.height, width: self.view.bounds.width, height: self.view.bounds.height - self.segmentView.frame.origin.y - self.segmentView.bounds.size.height - self.tabBarController!.tabBar.bounds.height - 60)
        self.view.addSubview(self.pageViewCntl!.view) 
        self.view.bringSubviewToFront(self.segmentView)
        self.setViewControllers(0, animationBool: true)
        
    }
    
    func setViewControllers(index:Int,animationBool:Bool)
    {
        let contentVwCntrollers:AZCommonViewController = self.viewControllerAtIndex(index)
        let startingViewController = [contentVwCntrollers]
        
        self.pageViewCntl?.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward, animated: animationBool, completion: nil)
        
    }
    
    func viewControllerAtIndex(index:Int)->AZCommonViewController
    {
        
            var viewStroyboardIDStr:String
            var viewTag = 0
        
            switch(index)
            {
            case 0:
                viewStroyboardIDStr = "AlbumsViewController"
                viewTag = 0
                break
                
            case 1:
                viewStroyboardIDStr = "SongsViewController"
                viewTag = 1
                break
                
            case 2:
                viewStroyboardIDStr = "ArtistsViewController"
                viewTag = 2
                break
                
            case 3:
                viewStroyboardIDStr = "GenreViewController"
                viewTag = 3

                break
                
            default:
                viewStroyboardIDStr = ""
                break
            }
            let contentViewController:AZCommonViewController = self.storyboard?.instantiateViewControllerWithIdentifier(viewStroyboardIDStr) as! AZCommonViewController
            contentViewController.view.tag = viewTag
            contentViewController.color = UIColor.whiteColor()
        
            return contentViewController
       
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index:Int = viewController.view.tag
            if (index == 3)
            {
                return nil
            }
            index++
            return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index:Int = viewController.view.tag
        if (index == 0)
        {
          return nil
        }
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentIndex:Int = (previousViewControllers[0] as UIViewController).view.tag
        
        if completed
        {
            self.typeSegmentedControl.selectedSegmentIndex = self.endingIndex
            
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        endingIndex = (pendingViewControllers[0] as! UIViewController).view.tag

    }
    
    @IBAction func actionForSelctedTab(sender: AnyObject)
    {
        let index:Int = (sender as! UISegmentedControl).selectedSegmentIndex
        
        self.setViewControllers(index, animationBool: false)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //
        
    }
 
    
}
