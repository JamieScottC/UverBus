//
//  HomeVC.swift
//  UverBus
//
//  Created by Jamie Scott on 1/27/19.
//  Copyright © 2019 UverBus. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox
import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit
class HomeVC: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate{
    //Globals
    let locationManager = CLLocationManager()
    
    var userLocation: CLLocationCoordinate2D!
    
    var ref: DatabaseReference!
    
    var etaDuration: Double!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var etaLabel: UILabel!
    
    var source: MGLShapeSource!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        ref = Database.database().reference()
        
        // Create a new map view using the Mapbox Dark style.
        mapView.frame = view.bounds
        
        mapView.styleURL = MGLStyle.darkStyleURL(withVersion: 9)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .gray
        //Track user
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        // Set the map view‘s delegate property and zoom level
        mapView.zoomLevel = 9
        mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLocation = locValue
    }
    
    //When follow user button is clicked
    @IBAction func followUserClicked(_ sender: UIButton) {
        //Start tracking user again
        mapView.setUserTrackingMode(.follow, animated: true)
        
    }
    
    //When the follow bus button is clicked
    @IBAction func followBusClicked(_ sender: UIButton) {
        //Find the bus coordinates in database
        ref.child("busLocation").child("geometry").observe(.value, with: {(snapshot ) in
            let value = snapshot.value as! NSDictionary
            let coordValues = value["coordinates"] as! NSArray
            let lat = coordValues[1] as! Double
            let long = coordValues[0] as! Double
            let coords = CLLocationCoordinate2DMake(lat, long)
            //Make sure we are not following user
            self.mapView.setUserTrackingMode(.none, animated: true)
            //Set the maps camera to where the bus is
            let camera = MGLMapCamera(lookingAtCenter: coords, altitude: self.mapView.camera.altitude, pitch: self.mapView.camera.pitch, heading: self.mapView.camera.heading)
            self.mapView.fly(to: camera, completionHandler: nil)
            

        })
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        //URL to database
        if let url = URL(string: "https://uverbus.firebaseio.com/busLocation.json") {
            // Add a source to the map. generates coordinates for simulated paths.
            source = MGLShapeSource(identifier: "schoolbus", url: url, options: nil)
            style.addSource(source)
            
            let droneLayer = MGLSymbolStyleLayer(identifier: "schoolbus", source: source)

            let busIcon = UIImage(named: "busIcon.png")
            style.setImage(busIcon!, forName: "busImage")
            droneLayer.iconImageName = NSExpression(forConstantValue: "busImage")
            droneLayer.iconScale = NSExpression(forConstantValue: 0.05)
            style.addLayer(droneLayer)
            
            // Create a timer that calls the `updateUrl` function every 1.5 seconds.
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateUrl), userInfo: nil, repeats: true)
        }
    }
    
    func calcETA(to: CLLocationCoordinate2D, from: CLLocationCoordinate2D){
        //URL to directions API
        let toLong = to.longitude
        let toLat = to.latitude
        let fromLong = from.longitude
        let fromLat = from.latitude
        print("long" + String(fromLong))
        print("lat" + String(fromLat))
        let urlStringA = "https://api.mapbox.com/directions-matrix/v1/mapbox/driving/" + String(toLong) + "," + String(toLat)
        let urlStringB = ";" + String(fromLong) + "," + String(fromLat) + "?approaches=curb;curb&access_token=pk.eyJ1IjoiamFtaWVzY290dGMiLCJhIjoiY2pyZ2pwc2tzMmxlNDN5cGdwamo0cXoyZCJ9.oYvpsFs_BmC85312NtD64Q"
        guard let gitUrl = URL(string: urlStringA + urlStringB)
        else { return }
        //Retrieve data from url
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                //Parse json
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(myDirections.self, from: data)
                print("website: " + urlStringA + urlStringB)
                self.updateEtaLabel(duration: gitData.durations![0][1])
                print(gitData.durations![0][1])
            } catch let err {
                print("Err", err)
            }
            }.resume()
        //print("other rr")
        
        
    }
    func updateEtaLabel(duration: Double){
        etaLabel.text = "ETA: " + String(duration)
    }
    @objc func updateUrl() {
        // Update the icon's position by setting the `url` property on the source.
        source.url = source.url
        //Also lets update the ETA while we're at it
        ref.child("busLocation").child("geometry").observe(.value, with: {(snapshot ) in
            let value = snapshot.value as! NSDictionary
            let coordValues = value["coordinates"] as! NSArray
            let lat = coordValues[1] as! Double
            let long = coordValues[0] as! Double
            
            let busLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.calcETA(to: self.userLocation, from: busLocation)
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Invalidate the timer if the view will disappear.
        timer.invalidate()
        timer = Timer()
    }
    
    
    //Struct for duration json
    struct myDirections: Codable{
        var code: String?
        var durations: [[Double]]?
    }
    
}
