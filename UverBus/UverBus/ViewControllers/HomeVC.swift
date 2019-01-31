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
class HomeVC: UIViewController, MGLMapViewDelegate{
    //Globals
    var ref: DatabaseReference!
    @IBOutlet weak var mapView: MGLMapView!
    var source: MGLShapeSource!
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
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
            print(coordValues)
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
    
    func drawPolyline(){
        
        
    }
    
    @objc func updateUrl() {
        // Update the icon's position by setting the `url` property on the source.
        source.url = source.url
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Invalidate the timer if the view will disappear.
        timer.invalidate()
        timer = Timer()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}