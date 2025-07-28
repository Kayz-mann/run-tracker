//
//  ActivityItemView.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 24/07/2025.
//

import SwiftUI
import Realtime
import MapKit

struct ActivityItemView: View {
    var run: RunPayload
    var body: some View {
        VStack (alignment: .leading){
            Text("Morning  Run")
                .font(.title3)
                .bold()
            Text(run.createdAt.formattedDate())
            HStack(spacing: 24) {
                VStack {
                    Text("Distance")
                        .font(.caption)
                    
                    Text("\(run.distance / 1000) km")
                }
                
                VStack {
                    Text("Pace")
                        .font(.caption)
                    
                    Text("\(Int(run.pace).convertDurationToString()) km")
                }
                
                VStack {
                    Text("Time")
                        .font(.caption)
                    
                    Text("\(run.time.convertDurationToString())")
                }
                
            }.padding(.vertical)
            Map {
                MapPolygon(coordinates: convertRouteToCoordinates(geoJSON: run.route))
                    .stroke(.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    func convertRouteToCoordinates(geoJSON: [GeoJSONCoordinate]) -> [CLLocationCoordinate2D] {
        return geoJSON.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }

}

#Preview {
    ActivityItemView(run: RunPayload(createdAt: .now, userId: .init(), distance: 12345, pace: 12, time: 1241, route: []))
}
