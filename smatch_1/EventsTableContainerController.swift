//
//  EventsTableContainerController.swift
//  smatch_1
//
//  Created by Kabir Khan on 5/8/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//

import UIKit

class EventsTableContainerController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    let delegate: EventsTableViewControllerDelegate = EventsTableViewController()
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        delegate.showWithOneSelectionFilters(sender)
    }
}

protocol EventsTableViewControllerDelegate {
    func showWithOneSelectionFilters(sender: AnyObject?)
}