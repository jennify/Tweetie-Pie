//
//  HamburgerViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/23/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    var originalLeftMargin: CGFloat?
    
    var contentViewController: UIViewController! {
        didSet(oldVC) {
            // Set up view in a hacky way -
            view.layoutIfNeeded()
            
            if oldVC != nil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.didMoveToParentViewController(nil)
            }
            
            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
        }
    }
    var menuViewController: MenuViewController! {
        didSet(oldVC) {
            // Set up view in a hacky way -
            view.layoutIfNeeded()
            
            if oldVC != nil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.didMoveToParentViewController(nil)
            }
            
            menuViewController.willMoveToParentViewController(self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMoveToParentViewController(self)
            
            // Animate the closing
            UIView.animateWithDuration(0.3, animations: {
                self.leftMarginConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }

    var isOpen: Bool! {
        didSet {
            if isOpen == true {
                UIView.animateWithDuration(0.3, animations: {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 100
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    self.leftMarginConstraint.constant = 0.0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isOpen = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hamburgerPressed", name: kHamburgerPressed, object: nil)
    }
    
    func hamburgerPressed ()    {
        if self.isOpen == true {
            self.isOpen = false
        } else {
            self.isOpen = true
        }
    }

    @IBAction func onPanGesture(sender: AnyObject) {
        // Cordinate system by current view
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        UIView.animateWithDuration(0.3, animations: {
            if sender.state == UIGestureRecognizerState.Began {
                self.originalLeftMargin = self.leftMarginConstraint.constant
            } else if sender.state == UIGestureRecognizerState.Changed {
                if translation.x > 0 {
                    self.leftMarginConstraint.constant = self.originalLeftMargin! + translation.x
                }
                
            } else if sender.state == UIGestureRecognizerState.Ended {
                if velocity.x > 0 {
                    self.isOpen = true
                } else {
                    self.isOpen = false
                }
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
