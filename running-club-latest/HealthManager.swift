//
//  HealthManager.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 29/07/2025.
//

import Foundation
import HealthKit

final class HealthManager {
    let healthStore = HKHealthStore()
    static let shared = HealthManager()
    
    private init() {}
    
    
    func requestAuthorization() async throws {
        let typesToShare: Set =  [HKWorkoutType.workoutType()]
        
        try await healthStore.requestAuthorization(toShare: typesToShare, read: [])
    }
    
    func addWorkout(startDate: Date, endDate: Date, duration: TimeInterval, distance: Double, kCalBurned: Double) async throws {
        let workout =  HKWorkout(activityType: .running, start: startDate, end: endDate, duration: duration, totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: kCalBurned),
                                 totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
                                 device: .local(), metadata: nil
        )
        
        try await healthStore.save(workout)
    }
}
