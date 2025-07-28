//
//  RunView.swift
//  run-tracker
//
//  Created by Balogun Kayode on 18/03/2025.
//

import SwiftUI
import AudioToolbox

struct RunView: View {
    @EnvironmentObject var runTracker: RunTracker
    
    var body: some View {
        VStack {
            // Top section with distance, BPM, and pace
            HStack {
                VStack {
                    Text("\(runTracker.distance, specifier: "%.2f") m")
                        .font(.title3)
                        .bold()
                    
                    Text("Distance")
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("BPM")
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(runTracker.pace) min/km")
                        .font(.title3)
                        .bold()

                    Text("Pace")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 80)
            
            // Timer in the middle
            VStack {
                Text("\(runTracker.elapsedTime.convertDurationToString())")
                    .font(.system(size: 64))
                
                Text("Time")
                    .foregroundStyle(.gray)
            }
            .frame(maxHeight: .infinity)
            
            // Bottom section with control buttons
            HStack {
                Button {
                    // Stop action
//                    runTracker.stopRun()
                } label: {
                    Image(systemName: "stop.fill")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding(34)
                        .background(.black)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .simultaneousGesture(LongPressGesture().onEnded({_ in
                    withAnimation{
                        runTracker.stopRun()
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}

                    }
   
                }))
                
                Spacer()
                
                Button {
                    // Pause action
                    if runTracker.isRunning {
                        runTracker.pauseRun()
                    }
                } label: {
                    Image(systemName: "pause.fill")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding(36)
                        .background(.black)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)

            }
            .padding()

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.yellow)
    }
}

#Preview {
    RunView()
        .environmentObject(RunTracker()) // Assuming you have a RunTracker class
}
