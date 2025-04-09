//
//  RunTracker.swift
//  run-tracker
//
//  Created by Balogun Kayode on 26/03/2025.
//

import Foundation
import SwiftUI
import MapKit

class RunTracker: NSObject, ObservableObject {
    @Published var isRunning =  false
    @Published var presentCountDown =  false
    @Published var presentRunView = false
    @Published var presentPauseView =  false
    @Published var distance = 0.0
    @Published var pace  = 0.0
    @Published var elapsedTime = 0
    private var timer: Timer?
    
    
    @Published var region =  MKCoordinateRegion(center: .init(latitude: 40.7120, longitude: 16.0060), span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
//    Location Tracking
    private var locationManager: CLLocationManager? //for firing location events
    private var startLocation: CLLocation?
    private var lastLocation: CLLocation?
    
//    override the initialized static variables for longitude and latititude
    override init() {
// super init is used when re initializing
        super.init()
//        run a task when RunTracker is called as a function
//        this task basically runs the request for location settings
        Task {
            await MainActor.run {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.startUpdatingLocation()
            }
        }
    }
    
    func startRun() {
        presentRunView =  true
        isRunning =  true
        startLocation = nil
        lastLocation = nil
        distance = 0.0
        pace = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            if self.distance > 0 {
                pace = (Double(self.elapsedTime)/60) / (self.distance / 1000)
            }
        }
        locationManager?.startUpdatingLocation()
    }
    
    func resumeRun() {
        isRunning =  true
        presentPauseView =  false
        presentRunView =  true
        startLocation = nil
        lastLocation = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            if self.distance > 0 {
                pace = (Double(self.elapsedTime)/60) / (self.distance / 1000)
            }
        }
        locationManager?.startUpdatingLocation()
    }
    
    func stopRun() {
        locationManager?.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        presentRunView =  false
        isRunning =  false
        presentPauseView =  false
    }
    
    func pauseRun(){
        isRunning =  false
        presentRunView =  false
        presentPauseView = true
        locationManager?.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

    }
    
    
}


//MARK: Location Tracking
extension RunTracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location  = locations.last else {return}
        
        Task {
            await MainActor.run {
                region.center = location.coordinate
            }
        }
        
        if startLocation == nil {
            startLocation = location
            lastLocation = location
            return
        }
        
        if let lastLocation {
            distance += lastLocation.distance(from: location)
        }
//        last location updates when there is a change in location
        lastLocation = location
    }
}
