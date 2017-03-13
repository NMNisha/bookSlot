//
//  Home.swift
//  bookSlot
//
//  Created by Mitosis on 07/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsCore

class Home: UIViewController {

    
    // IBOutlets
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var locationButton: UIButton!
    
    //User Coordinate from Search
    var locationManager = CLLocationManager()
    let lati = UserDefaults.standard.value(forKey: "latitude")
    let long = UserDefaults.standard.value(forKey: "longitude")
    let dataProvider = GoogleData()
    let searchRadius: Double = 3500
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant", "lodging"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
       initMap()
        mapView.addSubview(locationButton)// Custom myLocation Button
        
      
       self.navigationController?.navigationBar.barTintColor = UIColor.red
    }
//Load MapView User Searched userLocation 
    func initMap()
    {
         let userLocation = CLLocationCoordinate2D(latitude: lati as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
         mapView.camera = GMSCameraPosition(target: userLocation, zoom: 17, bearing: 0, viewingAngle: 0)
    fetchNearbyPlaces(userLocation)
        let marker = GMSMarker(position: userLocation)
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: UIColor.green)
        
    }
    
 // Reloading User Location
    @IBAction func locationTapped(_ sender: AnyObject) {
        let userLocation = CLLocationCoordinate2D(latitude: lati as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
        mapView.camera = GMSCameraPosition(target: userLocation, zoom: 17, bearing: 0, viewingAngle: 0)
    }
    
    func fetchNearbyPlaces(_ coordinate: CLLocationCoordinate2D) {
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            for place: GooglePlace in places {
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView

            }
        }
    }
    @IBAction func refreshPlaces(_ sender: AnyObject) {
        fetchNearbyPlaces(mapView.camera.target)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypesSegue" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TypesTableViewController
            controller.selectedTypes = searchedTypes
            controller.delegate = self
        }
    }
}
extension Home: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true, completion: nil)
        fetchNearbyPlaces(mapView.camera.target)
    }
}
