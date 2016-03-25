//
//  Sports.swift
//  smatch_1
//
//  Created by Kabir Khan on 3/22/16.
//  Copyright © 2016 Kabir Khan. All rights reserved.
//
//  GET THE BASE DATA FOR EACH SPORT FROM THE sports.plist FILE, THIS IS THE INFO ADDED TO USER PROFILES

import UIKit

// structure for a sport to be displayed when the users is asked to select specific sports for their profile
struct Sport {
    let name: String
    let iconImage: UIImage?
}

// MARK: ========================== EXTENSIONS  ==========================
// THESE EXTENSIONS ARE VITAL TO THE SPORT MODEL SO THEY BELONG HERE NOT 
// IN EXTENSIONS FOLDER

// initializer for a sport given a dictionary of plist values
extension Sport {
    init?(dict: [String: AnyObject]) {
        guard let name = dict["name"] as? String else {
                return nil
        }
        self.name = name
        
        // get image name from file and set self.image to be a UIImage with that name
        if let imageName = dict["icon_image_name"] as? String where !imageName.isEmpty {
            iconImage = UIImage(named: imageName)
        } else {
            iconImage = nil
        }
    }
}

extension Sport {
    static func loadDefaultSports() -> [Sport]? {
        return self.loadSportsFromPlistNamed("sports")
    }
    
    // actually load the sports from the plist
    static func loadSportsFromPlistNamed(plistName: String) -> [Sport]? {
        guard let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist"),
            let array = NSArray(contentsOfFile: path) as? [[String: AnyObject]] else {
                return nil
        }
        
        // map the array to a dictionary and filter out nil values
        return array.map { Sport(dict: $0) }
            .filter { $0 != nil }
            .map { $0! }
    }
}