//
//  SyncRouteViewController.swift
//  
//
//  Created by Wilson Ding on 10/2/16.
//
//

import UIKit
import MapKit
import AFNetworking
import SwiftyJSON
import GoogleMaps
import Firebase
import FirebaseDatabase

protocol HandleMapSearch: class {
    func findLocation(placemark:MKPlacemark)
}

class SyncRouteViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var myview: UIView!
    
    let mapSpan = 0.01
    
    let v = "54510212510202"
    var currentInt = 0

    var timer = Timer()
    
    var ref: FIRDatabaseReference!
    
    var link = ""
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var geoCoder: CLGeocoder! = CLGeocoder()
    var resultSearchController: UISearchController!
    
    var startLat, startLong, endLat, endLong: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myview.isHidden = true;
        
        getLocation()
    }
    
    @IBAction func selectionButtonPressed(_ sender: AnyObject) {
        let currentLocation = self.locationManager.location!.coordinate
        
        self.startLat = currentLocation.latitude
        self.startLong = currentLocation.longitude
        
        self.endLat = self.mapView.centerCoordinate.latitude
        self.endLong = self.mapView.centerCoordinate.longitude
        
        myview.isHidden = false;
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(SyncRouteViewController.color), userInfo: nil, repeats: true)
        var closerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(SyncRouteViewController.stopTimer), userInfo: nil, repeats: false)
    }
    
    func getLocation() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied: // No access to location services
                locationManager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse: // Access to location services
                locationManager.requestLocation()
                
                // Display location on map
                self.mapView.delegate = self
                mapView.showsUserLocation = true
            }
        } else { // Location services not enabled
            locationManager.requestAlwaysAuthorization()
        }
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for Places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func geoCode(location : CLLocation!){
        /* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
         one if we are getting location updates */
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc: CLPlacemark = placeMarks[0]
            let addressDict : [NSString:NSObject] = loc.addressDictionary as! [NSString: NSObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            let address =  addrList.joined(separator: ", ")
            self.addressLabel.text = address
        })
    }
    
    func sendToGoogleMaps() {
        let testURL = NSURL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL as URL) {
            link = "comgooglemaps-x-callback://?saddr=&daddr=\(endLat),\(endLong)&directionsmode=walking"
            sendToFB(string: link)
            recieveFromFB()
            let directionsURL = NSURL(string: link)!
            UIApplication.shared.openURL(directionsURL as URL)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.")
        }
    }
    
    func stopTimer() {
        timer.invalidate();
        myview.isHidden = true;
        sendToGoogleMaps()
    }
    
    func color(){
        if (currentInt >= v.characters.count) {
            currentInt = 0;
        } else {
            let temp = v[v.index(v.startIndex, offsetBy: currentInt)];
            
            if (currentInt > v.characters.count) {
                timer.invalidate();
            }
            
            currentInt+=1;
            if (temp == "5") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
            } else if (temp == "4") {
                myview.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
            }
            else if (temp == "2") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 255.0/255, alpha: 1.0)
            }
            else if (temp == "1") {
                myview.backgroundColor = UIColor(red: 0.0/255, green: 255.0/255, blue: 0.0/255, alpha: 1.0)
            }
            else if (temp == "0") {
                myview.backgroundColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
            }
            print("howdy")
        }
    }
    
    func sendToFB(string: String) {
        let post = ["read": "test"]
        let childUpdates = ["posts/": string]
        ref.updateChildValues(childUpdates)
    }
    
    func recieveFromFB() {
        var refHandle = ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as! [String : AnyObject]
            self.link = postDict["posts"]!["read"]!! as! String
        })
    }
}

extension SyncRouteViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = location!.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: mapSpan, longitudeDelta: mapSpan))
        
        self.mapView.setRegion(region, animated: true)
        
        geoCode(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager Error: \(error)")
    }
}

extension SyncRouteViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geoCode(location: location)
    }
}

extension SyncRouteViewController: HandleMapSearch {
    func findLocation(placemark: MKPlacemark){
        let span = MKCoordinateSpanMake(mapSpan, mapSpan)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
