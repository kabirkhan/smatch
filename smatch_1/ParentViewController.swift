//
//  CreateEventFinish.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/28/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  Container View Controller to handle the transition between the events table view
//  to the events map view controllers from the top custom segmented control

import UIKit

class ParentViewController: UIViewController {
    
    //--------------------------------------------------
    // MARK: - Variables
    //--------------------------------------------------
    enum TabIndex : Int {
        case FirstChildTab = 0
        case SecondChildTab = 1
        case ThirdChildTab = 2
    }
    
    var currentViewController: UIViewController?
    
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("FirstViewControllerID")
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("SecondViewControllerID")
        return secondChildTabVC
    }()
    
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("ThirdViewControllerID")
        return thirdChildTabVC
    }()

    
    //--------------------------------------------------
    // MARK: - Outlets
    //--------------------------------------------------
    @IBOutlet private weak var segmentedControl: TopTabSegmentedControl!
    @IBOutlet private weak var contentView: UIView!

    //--------------------------------------------------
    // MARK: - View LifeCycle
    //--------------------------------------------------
    
    /*
        Setup navbar shadow and fonts.
        Initialize UI of segmented control.
        Initialize Tab index
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.removeShadowOnBottomOfBarAndSetColorWith(UIColor.materialMainGreen)
        self.navigationController?.navigationBar.setNavbarFonts()
        
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
        displayCurrentTab(TabIndex.FirstChildTab.rawValue)
    }
    
    /*
        If parent ViewController dissapears, tell the child 
        ViewController to dissapear as well
     */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    //--------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------
    
    /*
        Remove current ViewController in container.
        Display the next ViewController from the tab index selected.
     */
    @IBAction func switchTabs(sender: UISegmentedControl) {
        
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    //--------------------------------------------------
    // MARK: - Helper Functions
    //--------------------------------------------------
    
    /*
        Given the index of the segmented control
        display the correct ViewController
     */
    func displayCurrentTab(tabIndex: Int) {
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    /*
        Given an index, return the correct ViewController for that index.
     */
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
