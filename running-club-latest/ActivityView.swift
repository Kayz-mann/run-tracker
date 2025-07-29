//
//  ActivityView.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 03/06/2025.
//

import SwiftUI

struct ActivityView: View {
    @State var activities =  [RunPayload]()
    

    
    var body: some View {
        NavigationStack {
            List {
                ForEach(activities) { run in
                    NavigationLink {
                        ActivityItemView(run: run)
                    } label: {
                        VStack (alignment: .leading){
                            Text(run.createdAt.timeOfDayString())
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
                                    
                                    Text("\(Int(run.pace, specifier : "%.2f")) mins")
                                }
                                
                                VStack {
                                    Text("Time")
                                        .font(.caption)
                                    
                                    Text("\(run.time.convertDurationToString())")
                                }
                                
                            }.padding(.vertical)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        Task {
                            do {
                                try await AuthService.shared.logout()
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            Text("Logout")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        guard let userId =  AuthService.shared.currentSession?.user.id else {return}
                        activities =  try await DatabaseService.shared.fetchWorkouts(for: userId)
                        
                        activities.sort(by: {$0.createdAt >= $1.createdAt})
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
}

#Preview {
    ActivityView()
}
