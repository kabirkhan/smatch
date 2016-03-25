//
//  ParentViewController.swift
//  UISegmentedControlAsTabbarDemo
//
//  Created by Ahmed Abdurrahman on 9/15/15.
//  Copyright © 2015 A. Abdurrahman. All rights reserved.
//
//  Container View Controller to handle the transition between the events table view
//  to the events map view controllers from the top custom segmented control

import UIKit

class ParentViewController: UIViewController {

    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
        case ThirdChildTab = 2
    }

    @IBOutlet weak var segmentedControl: TopTabSegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("FirstViewControllerId")
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("SecondViewControllerId")
        return secondChildTabVC
    }()
    
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("ThirdViewControllerId")
        return thirdChildTabVC
    }()

    

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove the shadow between navbar and segmented controller
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.barTintColor = UIColor.materialMainGreen
        self.navigationController?.navigationBar.backgroundColor = UIColor.materialMainGreen
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        segmentedControl.layer.shadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).CGColor
        segmentedControl.layer.shadowOpacity = 0.8
        segmentedControl.layer.shadowRadius = 5.0
        segmentedControl.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
        displayCurrentTab(TabIndex.FirstChildTab.rawValue)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    // MARK: - Switching Tabs Functions
    @IBAction func switchTabs(sender: UISegmentedControl) {
        
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    func displayCurrentTab(tabIndex: Int) {
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(index: Int) -> UIViewController? {

        switch index {
        case TabIndex.FirstChildTab.rawValue :
            return firstChildTabVC
        case TabIndex.SecondChildTab.rawValue :
            return secondChildTabVC
        case TabIndex.ThirdChildTab.rawValue :
            return thirdChildTabVC
        default:
            return nil
        }
    }
}
