import Foundation
import UIKit
import RxSwift
import CoreLocation
import CoreMotion

///Default implementation for the location service.
class DefaultLocationService : NSObject, CLLocationManagerDelegate, LocationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    
    ///The location manager itself
    private let locationManager = CLLocationManager()
    
    private var locationVariable = Variable(CLLocation())
    
    // for logging date/time of received location updates
    private let dateTimeFormatter = DateFormatter()
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = Constants.distanceFilter
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.activityType = .other
        
        self.dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.loggingService.log(withLogLevel: .verbose, message: "DefaultLocationService Initialized")
    }
    
    //MARK: LocationService implementation
    
    lazy private(set) var locationObservable : Observable<CLLocation> =
    {
        return self.locationVariable
                .asObservable()
                .filter(self.filterLocations)
    }()
    
    func startLocationTracking()
    {
        self.loggingService.log(withLogLevel: .debug, message: "DefaultLocationService started")
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopLocationTracking()
    {
        self.loggingService.log(withLogLevel: .debug, message: "DefaultLocationService stoped")
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func getLastKnownLocation() -> CLLocation?
    {
        return self.locationManager.location
    }
    
    //MARK: CLLocationManagerDelegate Implementation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //Notifies new locations to listeners
        locations.forEach { location in self.locationVariable.value = location }
    }
    
    //MARK: Methods
    private func filterLocations(_ location: CLLocation) -> Bool
    {
        //Location is valid
        guard location.coordinate.latitude != 0.0 && location.coordinate.latitude != 0.0 else
        {
            self.logLocationUpdate(location, "Received an invalid location")
            return false
        }
                
        //Location is accurate enough
        guard 0 ... 2000 ~= location.horizontalAccuracy else
        {
            self.logLocationUpdate(location, "Received an inaccurate location")
            return false
        }
        
        self.logLocationUpdate(location, "Received a valid location")
        return true
    }
    
    private func logLocationUpdate(_ location: CLLocation, _ message: String)
    {
        let text = "\(message) <\(location.coordinate.latitude),\(location.coordinate.longitude)>"
                 + " ~\(max(location.horizontalAccuracy, location.verticalAccuracy))m"
                 + " (speed: \(location.speed)m/s course: \(location.course))"
                 + " at \(dateTimeFormatter.string(from: location.timestamp))"
        
        self.loggingService.log(withLogLevel: .debug, message: text)
    }
}
