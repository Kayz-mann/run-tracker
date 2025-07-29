//
//  DatabaseService.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 02/06/2025.
//

import Foundation
import Supabase

enum Table: String {
    case workouts = "workouts"
}

struct RunPayload: Identifiable, Codable {
    var id: Int?
    let createdAt: Date
    let userId: UUID
    let distance: Double
    let pace: Double
    let time: Int
    let route: [GeoJSONCoordinate]
    
    
    enum CodingKeys: String, CodingKey {
        case id, distance, pace, time, route
        case createdAt = "created_at"
        case userId = "user_id"
    }
}

struct GeoJSONCoordinate: Codable {
    let longitude: Double
    let latitude: Double
}

final class DatabaseService {
    static let shared =  DatabaseService()
    private var supabase =  SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseKEY)
    
    private init () {}
    
    func saveWorkout(run: RunPayload) async throws {
        let _ =  try await supabase.from(Table.workouts.rawValue).insert(run).execute().value
        
        
        print("Saved to db")
    }
    
    func fetchWorkouts(for userId: UUID) async throws -> [RunPayload] {
        return try await supabase.from(Table.workouts.rawValue).select().in("user_id", values: [userId]).execute().value
    }
    
    
}
