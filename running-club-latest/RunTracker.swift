//
//  RunTracker.swift
//  run-tracker
//
//  Created by Balogun Kayode on 26/03/2025.
//

import Foundation
import SwiftUI
import MapKit
import Supabase

class RunTracker: NSObject, ObservableObject {
    @Published var isRunning =  false
    @Published var presentCountDown =  false
    @Published var presentRunView = false
    @Published var presentPauseView =  false
    @Published var distance = 0.0
    @Published var pace  = 0.0
    @Published var elapsedTime = 0
    private var timer: Timer?
    private var startTime =  Date.now
    
    @Published var region =  MKCoordinateRegion(center: .init(latitude: 40.7120, longitude: 16.0060), span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    // Location Tracking
    private var locationManager: CLLocationManager? //for firing location events
    private var startLocation: CLLocation?
    private var lastLocation: CLLocation?
    private var locations: [CLLocation] = []
    
    // override the initialized static variables for longitude and latitude
    override init() {
        // super init is used when re initializing
        super.init()
        // run a task when RunTracker is called as a function
        // this task basically runs the request for location settings
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
        locations = [] // Reset locations array
        distance = 0.0
        pace = 0.0
        elapsedTime = 0 // Reset elapsed time
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            if self.distance > 0 {
                self.pace = (Double(self.elapsedTime)/60) / (self.distance / 1000)
            }
        }
        locationManager?.startUpdatingLocation()
    }
    
    func resumeRun() {
        isRunning =  true
        presentPauseView =  false
        presentRunView =  true
        // Don't reset startLocation and lastLocation when resuming
        // Don't reset locations array when resuming
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            if self.distance > 0 {
                self.pace = (Double(self.elapsedTime)/60) / (self.distance / 1000)
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
        postToDB()
        postToHealthStore()
        startTime = .now
    }
    
    func postToDB() {
        Task {
            do {
                guard let userId =  AuthService.shared.currentSession?.user.id else {return}
                // Convert CLLocation array to coordinate array, then to GeoJSON
                let coordinates = convertToGeoJSONCoordinates(locations: locations.map { $0.coordinate })
                let run =  RunPayload(createdAt: .now, userId: userId, distance: distance, pace: pace, time: elapsedTime, route: coordinates)
                try await DatabaseService.shared.saveWorkout(run: run)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func pauseRun(){
        isRunning =  false
        presentRunView =  false
        presentPauseView = true
        locationManager?.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }
    
    func postToHealthStore() {
        Task {
            do {
                try await HealthManager.shared.addWorkout(startDate: startTime, endDate: .now, duration: Double(elapsedTime), distance: distance, kCalBurned: calculateKCalBurned())
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func calculateKCalBurned() -> Double {
        let weight: Double =  80
        let duration: Double =  Double(elapsedTime) / (60*60)
        let kilos =  distance / 1000
        let met = (1.57) * (kilos/duration) - 3.15
        print("values",weight, duration, met)
        return met * weight * duration
        
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
        
        self.locations.append(location)
        
        if startLocation == nil {
            startLocation = location
            lastLocation = location
            return
        }
        
        if let lastLocation {
            distance += lastLocation.distance(from: location)
        }
        // last location updates when there is a change in location
        lastLocation = location
    }
}

// Fixed function with proper closure syntax
func convertToGeoJSONCoordinates(locations: [CLLocationCoordinate2D]) -> [GeoJSONCoordinate] {
    return locations.map { coordinate in
        GeoJSONCoordinate(longitude: coordinate.longitude, latitude: coordinate.latitude)
    }
}

