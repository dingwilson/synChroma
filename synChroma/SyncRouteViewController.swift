//
//  SyncRouteViewController.swift
//  
//
//  Created by Wilson Ding on 10/2/16.
//
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func findLocation(placemark:MKPlacemark)
}

class SyncRouteViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    let mapSpan = 0.01
    
    var locationManager: CLLocationManager! = CLLocationManager()
    var geoCoder: CLGeocoder! = CLGeocoder()
    var resultSearchController: UISearchController!
    
    var startLat, startLong, endLat, endLong: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocation()
    }
    
    @IBAction func selectionButtonPressed(_ sender: AnyObject) {
        let currentLocation = self.locationManager.location!.coordinate
        
        self.startLat = currentLocation.latitude
        self.startLong = currentLocation.longitude
        
        self.endLat = self.mapView.centerCoordinate.latitude
        self.endLong = self.mapView.centerCoordinate.longitude
        
        sendToGoogleMaps()
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
//        apiKey = "AIzaSyDMS6wFyJYTetjrYuRre1e_DTppRvf6eeY"
//        var urlString = "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(startLat),\(startLong)&destination=\(destLatitude),\(destLongitude)&sensor=true&key=\(apiKey)"
//        
//        urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
//        
//        let manager=AFHTTPRequestOperationManager()
//        
//        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments) as AFJSONResponseSerializer
//        
//        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
//        
//        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/html", "text/plain", "text/json", "text/javascript", "audio/wav") as Set<NSObject>
//        
//        
//        manager.post(urlString, parameters: nil, constructingBodyWith: { (formdata:AFMultipartFormData!) -> Void in
//            
//            }, success: {  operation, response -> Void in
//                //{"responseString" : "Success","result" : {"userId" : "4"},"errorCode" : 1}
//                //if(response != nil){
//                let parsedData = JSON(response)
//                print_debug("parsedData : \(parsedData)")
//                var path = GMSPath.init(fromEncodedPath: parsedData["routes"][0]["overview_polyline"]["points"].string!)
//                //GMSPath.fromEncodedPath(parsedData["routes"][0]["overview_polyline"]["points"].string!)
//                var singleLine = GMSPolyline.init(path: path)
//                singleLine.strokeWidth = 7
//                singleLine.strokeColor = UIColor.green
//                singleLine.map = self.mapView
//                //let loginResponeObj=LoginRespone.init(fromJson: parsedData)
//                
//                
//                //  }
//            }, failure: {  operation, error -> Void in
//                
//                print_debug(error)
//                let errorDict = NSMutableDictionary()
//                errorDict.setObject(ErrorCodes.errorCodeFailed.rawValue, forKey: ServiceKeys.keyErrorCode.rawValue as NSCopying)
//                errorDict.setObject(ErrorMessages.errorTryAgain.rawValue, forKey: ServiceKeys.keyErrorMessage.rawValue as NSCopying)
//                
//        })
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
