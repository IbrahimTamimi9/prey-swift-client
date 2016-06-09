//
//  GeofencingManager.swift
//  Prey
//
//  Created by Javier Cala Uribe on 9/06/16.
//  Copyright © 2016 Fork Ltd. All rights reserved.
//

import Foundation
import CoreLocation

// Prey geofencing definitions
enum kGeofence: String {
    case IN         = "geofencing_in"
    case OUT        = "geofencing_out"
    case INFO       = "info"
    case NAME       = "name"
    case ZONEID     = "id"
}


class GeofencingManager:NSObject, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    static let sharedInstance = GeofencingManager()
    override private init() {
        
        // Init location manager
        geoManager = CLLocationManager()

        // Init object
        super.init()
        
        // Delegate location manager
        geoManager.delegate = self
    }

    let geoManager: CLLocationManager
    
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("GeofencingManager: Did start monitoring for region")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("GeofencingManager Error: \(error)")
    }

    // Enter Region
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("GeofencingManager: Did enter region")
    
        if let regionIn:CLCircularRegion = region as? CLCircularRegion {
            let params = getParamteresToSend(regionIn, withZoneInfo:kGeofence.IN.rawValue)
            sendNotifyToPanel(params)
        }
    }
    
    // Exit Region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("GeofencingManager: Did exit region")
        
        if let regionIn:CLCircularRegion = region as? CLCircularRegion {
            let params = getParamteresToSend(regionIn, withZoneInfo:kGeofence.OUT.rawValue)
            sendNotifyToPanel(params)
        }
    }
    
    // Params to send
    func getParamteresToSend(region:CLCircularRegion, withZoneInfo zoneInfo:String) -> [String: AnyObject] {
        
        let regionInfo:[String: AnyObject] = [
            kGeofence.ZONEID.rawValue       : region.identifier,
            kLocation.LONGITURE.rawValue    : region.center.latitude,
            kLocation.LATITUDE.rawValue     : region.center.longitude,
            kLocation.ACCURACY.rawValue     : region.radius,
            kLocation.METHOD.rawValue       : "native"]

        let params:[String: AnyObject] = [
            kGeofence.INFO.rawValue         : regionInfo,
            kGeofence.NAME.rawValue         : zoneInfo]
        
        return params
    }
    
    // Send to panel
    func sendNotifyToPanel(params:[String: AnyObject]) {
        // Check userApiKey isn't empty
        if let username = PreyConfig.sharedInstance.userApiKey {
            PreyHTTPClient.sharedInstance.userRegisterToPrey(username, password:"x", params:params, httpMethod:Method.POST.rawValue, endPoint:eventsDeviceEndpoint, onCompletion:PreyHTTPResponse.checkDataSend(nil))
        } else {
            print("Error send data auth")
        }
    }
}