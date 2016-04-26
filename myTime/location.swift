//
//  location.swift
//  myTime
//
//  Created by Marcus on 4/8/16.
//  Copyright © 2016 Marcus. All rights reserved.
//

import Foundation

class Location: NSObject, NSCoding {
    // MARK: Properties
    
    var hour: Int
    var minute: Int
    var location: String
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("locations")
    
    // MARK: Types
    
    struct PropertyKey {
        static let hourKey = "hour"
        static let minuteKey = "minute"
        static let locationKey = "location"
    }
    
    // MARK: Initialization
    
    init?(hour: Int, minute: Int, location: String) {
        // Initialize stored properties.
        self.hour = hour
        self.minute = minute
        self.location = location
        
        super.init()
        
        // Initialization should fail if there is no hour or if the location is negative.
        if location.isEmpty{
            print("no Location")
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(hour, forKey: PropertyKey.hourKey)
        aCoder.encodeInteger(minute, forKey: PropertyKey.minuteKey)
        aCoder.encodeObject(location, forKey: PropertyKey.locationKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let hour = aDecoder.decodeIntegerForKey(PropertyKey.hourKey)
        
        let minute = aDecoder.decodeIntegerForKey(PropertyKey.minuteKey)
        
        let location = aDecoder.decodeObjectForKey(PropertyKey.locationKey) as! String

        self.init(hour: hour, minute: minute, location: location)
    }
    
}