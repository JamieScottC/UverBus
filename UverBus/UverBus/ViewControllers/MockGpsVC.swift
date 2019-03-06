//
//  MockGpsVC.swift
//  UverBus
//
//  Created by Jamie Scott on 2/28/19.
//  Copyright © 2019 UverBus. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
class MockGpsVC: UIViewController, CLLocationManagerDelegate {
    var userLocation: CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager()

    var timer = Timer()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //Location stuff...
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendCoords), userInfo: nil, repeats: true)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLocation = locValue
    }
    
   @objc func sendCoords(){
    print("GPS: " + String(userLocation.latitude))
        ref.child("busLocation").child("geometry").child("coordinates").child("0").setValue(userLocation.longitude)
        ref.child("busLocation").child("geometry").child("coordinates").child("0").setValue(userLocation.latitude)
    }
    


}
