//
//  ViewController.swift
//  myTime
//
//  Created by Marcus on 4/4/16.
//  Copyright © 2016 Marcus. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate{
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var infoLabel: UILabel!
    var coreLocationController:CoreLocationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationController = CoreLocationController()
        coreLocationController!.textArea = textArea
        coreLocationController!.infoLabel = infoLabel
        coreLocationController!.mapView = mapView
        mapView.showsUserLocation = true

        // Do any additional setup after loading the view, typically from a nib.
        coreLocationController?.printLocations()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

