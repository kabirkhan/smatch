//
//  ChooseSportsCollectionViewController.swift
//  smatch
//
//  Created by Kabir Khan on 3/16/16.
//  Copyright © 2016 blueberries. All rights reserved.
//
//  Collection View to display all the available sports that
//  a user can participate in. Get the selected cells and set 
//  them as the user's sports.

import UIKit

class ChooseSportsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: ===================== OUTLETS =====================
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: ===================== VIEW LIFECYCLE =====================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // set collection view item size to be half the 
        // width of the frame to create two columns
        let width = CGRectGetWidth(view.frame) / 2 - 1
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    // MARK: ============== COLLECTION VIEW DATA SOURCE ================
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("sportscell", forIndexPath: indexPath)
        return cell
    }
    
}
