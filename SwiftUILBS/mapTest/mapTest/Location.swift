//
//  Location.swift
//  mapTest
//
//  Created by Junjie Li on 11/12/21.
//

import Foundation
import CoreLocation


class Location: NSObject, ObservableObject, CLLocationManagerDelegate{
    private var locationManager: CLLocationManager
    
    @Published
    var locations = [CLLocationCoordinate2D]()
    
    //location change
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //average
        var latitude: CLLocationDegrees = 0
        var longitude: CLLocationDegrees = 0
        for location in locations {
            latitude += location.coordinate.latitude
            longitude += location.coordinate.longitude
        }
        latitude /= Double(locations.count)
        longitude /= Double(locations.count)
        //append
        self.locations.append(ZJ_MapKits()
                                .transformFromWGSToGCJ(wgsLoc: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
    }
    
    //error resolve
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //initialization
    override init(){
        locationManager = CLLocationManager()
        //configuration default
        locationManager.distanceFilter = 2
        //default accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.requestAlwaysAuthorization()
        permission = locationManager.authorizationStatus
        locationManager.startUpdatingLocation()
        
        super.init()
        
        //location delegate
        locationManager.delegate = self
    }
    
    @Published
    var permission: CLAuthorizationStatus
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //update
        permission = locationManager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedAlways{
            locationManager.allowsBackgroundLocationUpdates = true
            manager.startUpdatingLocation();
        }
        else if manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.allowsBackgroundLocationUpdates = false
            manager.startUpdatingLocation();
        }
        else{
            manager.stopUpdatingLocation()
        }
    }
    
    func requestPermission(){
        locationManager.requestAlwaysAuthorization()
    }
    
    
    func changeDesiredAccuracy(distanceFilte: CLLocationDistance){
        locationManager.distanceFilter = distanceFilte
    }
}
