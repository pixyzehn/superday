import Foundation
import UIKit
import CoreLocation
import CoreMotion
import UIKit

class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    typealias LocationServiceCallback = CLLocation -> ()
    
    private let distanceFilter = 100.0
    private var onLocationCallbacks = [LocationServiceCallback]()
    private let locationManager = CLLocationManager()
    private var timer : NSTimer? = nil
    
    override init()
    {
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = distanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .Other
        locationManager.pausesLocationUpdatesAutomatically = true
        
        if Double(UIDevice.currentDevice().systemVersion) >= 8.0
        {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startLocationTracking()
    {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationTracking()
    {
        locationManager.stopUpdatingLocation()
    }
    
    func subscribeToLocationChanges(onLocationCallback: LocationServiceCallback)
    {
        onLocationCallbacks.append(onLocationCallback)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let lastLocation = locations.filter(filterLocations).last else { return }
        
        //Notifies new location to listeners
        onLocationCallbacks.forEach { callback in callback(lastLocation) }
        
        if timer != nil && timer!.valid { return }
        
        //Schedules tracking to restart in 1 minute
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(startLocationTracking), userInfo: nil, repeats: false)
        
        //Stops tracker after 10 seconds
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(stopLocationTracking), userInfo: nil, repeats: false);
    }
    
    private func filterLocations(location: CLLocation) -> Bool
    {
        //Location is valid
        guard location.coordinate.latitude != 0.0 && location.coordinate.latitude != 0.0 else { return false }
        
        //Location is up-to-date
        let locationAge = -location.timestamp.timeIntervalSinceNow
        guard locationAge > 30 else { return false }
        
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else { return false }
        
        return true
    }
}