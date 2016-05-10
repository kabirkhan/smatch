//
//  NSDate.swift
//  smatch
//
//  Created by Kabir Khan on 5/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension NSDate {
    /*
        Format a date to a more readable format
        (Day of week, Month name and month day,
        Time in hours:mm and am or pm)
     */
    func formatDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE MMM d, h:mm a"
        return dateFormatter.stringFromDate(self)
    }
}