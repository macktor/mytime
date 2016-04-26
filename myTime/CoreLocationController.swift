//
//  CoreLocationController.swift
//  myTime
//
//  Created by Marcus on 4/8/16.
//  Copyright © 2016 Marcus. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class CoreLocationController : NSObject, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let kmeanCalc: KMean = KMean()
    var places: [[Double]]!
    var textArea: UITextView!
    var infoLabel: UILabel!
    var mapView: MKMapView!
    var locations = [Location]()
    var loadedLocations = [Location]()
    var i: Int = 1
    var locationText: String!
    var timeStamp: String!
    var text: String = ""
    var first = true

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        print("init CLC")
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            break
            
        case .Authorized:
            print(".Authorized")
            self.locationManager.startMonitoringSignificantLocationChanges()
            break
            
        case .Denied:
            print(".Denied")
            break
            
        default:
            print("Unhandled authorization status")
            break
            
        }
    }
    func addPreviousLocations(oldLocations: [Location]) {
        for l in oldLocations{
            locations.append(l)
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations contains an array of recent locations, but this app only cares about the most recent
        // which is also "manager.location"
        //print("Found Location")
        foundLocation(manager.location) // update the user object in this method
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed with error: %@", error)
        if error.domain == kCLErrorDomain && CLError(rawValue: error.code) == CLError.Denied {
            //user denied location services so stop updating manager
            manager.stopUpdatingLocation()
        }
    }
    func foundLocation(location: CLLocation!) {
        //print("Printing location")
        if (location) == nil {
            return
        }
        let lat = String(location.coordinate.latitude)
        let lng = String(location.coordinate.longitude)

        
        addLocationToMap(location.coordinate)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minute = components.minute
        let location = lat + " " + lng
        print("[" + lat + ", " + lng + "," + String((hour*60 + minute)) + "]")
        
        locations.append(Location(hour: hour, minute: minute, location: location)!)
        saveLocations()
        printLocations()

        
    }
    func printLocations() {
        if let savedLocations = loadLocation(){
            //print("We got something from loadLocation() " + String(savedLocations.count))
            loadedLocations = savedLocations
        }
        if loadedLocations.count > 0{
            //addPreviousLocations(locations)
            var data: [[Double]] = []
            var timestamps: [Double] = []
            text = ""
            for l in loadedLocations {
                let latlng = l.location.componentsSeparatedByString(" ") as [NSString]
                let lat = latlng[0].doubleValue
                let lng = latlng[1].doubleValue
                let hour = Double(l.hour)
                let minute = Double(l.minute)
                
                data.append([lat, lng])
                timestamps.append(hour*60+minute)
                
                if first == true {
                    //addLocationToMap(CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: lng as CLLocationDegrees))
                }
                locationText = "\n\nLocation: " + (latlng[0] as String) + " | " + (latlng[1] as String)
                timeStamp = "\n    at: " + String(l.hour) + ":" + String(l.minute)
                text += locationText + timeStamp
                
            }
            kmeanCalc.doTheWork(data, timestamps: timestamps)
                //places = kmeanCalc.clusters
                //for p in places {
                //    addLocationToMap(CLLocationCoordinate2D(latitude: p[0] as CLLocationDegrees, longitude: p[1] as CLLocationDegrees))
                //}
            
            infoLabel.text = String(loadedLocations.count) + " locations found. " + String(kmeanCalc.clusters.count) + " Clusters found"
            textArea.text = text
            let bottom: NSRange = NSMakeRange(textArea.text.characters.count, 1)
            textArea.scrollRangeToVisible(bottom)
        }
        else {
            infoLabel.text = "No Data Available"
        }
        first = false
        
    }
    
    
    func loadLocation() -> [Location]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Location.ArchiveURL.path!) as? [Location]
    }

    func addLocationToMap(coordinate: CLLocationCoordinate2D) {
        print("Adding Pin to map @ " + String(coordinate))
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        print("Now we have " + String(mapView.annotations.count) + " annotations")
    }
    func saveLocations(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: Location.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save locations...")
        }
        else {
            //print(String(i) + " Locations saved this session")
            i += 1
        }
    }
    
}