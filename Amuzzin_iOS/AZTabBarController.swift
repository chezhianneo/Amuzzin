//
//  AZTabBarController.swift
//  Amuzzin_iOS
//
//  Created by Chezhian Arulraj on 15/04/15.
//  Copyright (c) 2015 Chezhian Arulraj. All rights reserved.
//


//50,54,57
//e24e40 = 208,48,55

//http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/

import UIKit

class AZTabBarController: UITabBarController
{


    var playVwCntrl:AZNowPlayingViewController!
    var startlocation:CGPoint!,stoplocation:CGPoint!,changelocation:CGPoint!
    var swipeUp:Bool = false
    var topConstraint:NSLayoutConstraint?

    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("handleSwipeGestureRecogonizer:"))
        playVwCntrl = self.storyboard?.instantiateViewControllerWithIdentifier("NowPlaying")  as! AZNowPlayingViewController
        //playVwCntrl.view.frame = CGRectZero

        //playVwCntrl.view.frame = CGRectMake(0, 558, SCREEN_WIDTH, SCREEN_HEIGHT)
        
        self.view.addSubview(playVwCntrl.view)
        
        self.playVwCntrl.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint( NSLayoutConstraint(item: self.playVwCntrl.view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint( NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.playVwCntrl.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0))

        self.playVwCntrl.view.addConstraint(NSLayoutConstraint(item: self.playVwCntrl.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: SCREEN_HEIGHT))
        self.topConstraint =  NSLayoutConstraint(item: self.playVwCntrl.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: self.tabBar.frame.origin.y - 60)
        self.view.addConstraint(self.topConstraint!)

        self.playVwCntrl.view.addGestureRecognizer(gesture)
        self.view.bringSubviewToFront(self.tabBar)
        self.tabBar.barTintColor = UIColor(red: 50, green: 54, blue: 57, alpha: 0.1)

//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
//        visualEffectView.frame = self.tabBar.bounds
//        
//        self.tabBar.addSubview(visualEffectView)
//        self.tabBar.sendSubviewToBack(visualEffectView)
    }
    
    func handleSwipeGestureRecogonizer(senderGesture:UIPanGestureRecognizer)
    {
        let navCntrl = self.selectedViewController as! UINavigationController
        let initiallocation:CGFloat = self.topConstraint!.constant
        initiallocation
        
        if senderGesture.state == UIGestureRecognizerState.Began
        {
            let velocity = senderGesture.velocityInView(self.view)

            self.startlocation = senderGesture.locationInView(self.view)
            
       //     NSLog("Start Location %@ Velocity %@",NSStringFromCGPoint(startlocation),NSStringFromCGPoint(velocity))
            

        }
        else if senderGesture.state == UIGestureRecognizerState.Changed
        {
            self.changelocation = senderGesture.translationInView(self.view)
         //   NSLog("Change Location %@" ,NSStringFromCGPoint(changelocation))

           // self.playVwCntrl.view.frame = CGRectMake(0, self.startlocation.y - navCntrl.navigationBar.frame.size.height + self.changelocation.y, SCREEN_WIDTH, SCREEN_HEIGHT)
            
            self.topConstraint?.constant = self.changelocation.y - navCntrl.navigationBar.frame.size.height + self.startlocation.y + 20
            
           // self.playVwCntrl.view.layoutIfNeeded()
            
            if self.changelocation.y < 0
            {
                self.swipeUp = true
            }
            else
            {
                self.swipeUp = false
            }
            
        }
        else if senderGesture.state == UIGestureRecognizerState.Ended
        {
            if self.swipeUp
            {
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.topConstraint?.constant = 20
                        self.playVwCntrl.view.layoutIfNeeded()


//                        self.playVwCntrl.view.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT)
//                        navCntrl.setNavigationBarHidden(true, animated: true)
                        
                    }, completion:{(bool:Bool) in
                    
                        self.playVwCntrl.barPlay.hidden = true
                    }
                    )
        }
        else
        {

            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.topConstraint?.constant = self.tabBar.frame.origin.y - 60

                    self.playVwCntrl.view.layoutIfNeeded()

//                    self.playVwCntrl.view.frame = CGRectMake(0, 558, SCREEN_WIDTH, SCREEN_HEIGHT)
//                    navCntrl.setNavigationBarHidden(false, animated: true)
                }, completion:{(bool:Bool) in
                    self.playVwCntrl.barPlay.hidden = false
                }
            )
            }
        }
    }
    

    
}
