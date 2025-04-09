//
//  Pause.swift
//  run-tracker
//
//  Created by Balogun Kayode on 05/04/2025.
//

import SwiftUI
import AudioToolbox

struct Pause: View {
    @EnvironmentObject var runTracker: RunTracker
    var body: some View {
        VStack {
            AreaMap(region: $runTracker.region)
                .ignoresSafeArea()
                .frame(height: 300)
            
            HStack{
                VStack{
                    Text("\(runTracker.distance / 1000, specifier: "%.2f")")
                        .font(.title3)
                        .bold()
                    
                    Text("Km")
                }
                .frame(maxWidth: .infinity)
                
                VStack{
                    Text("\(runTracker.pace, specifier: "%.2f") min/km")
                        .font(.title3)
                        .bold()
                    
                    Text("Avg Pace")
                }
                .frame(maxWidth: .infinity)

                
                VStack{
                    Text("\(runTracker.elapsedTime.convertDurationToString())")
                        .font(.title3)
                        .bold()
                    
                    Text("Time")
                }
                .frame(maxWidth: .infinity)

            }.padding()
            
            HStack{
                VStack{
                    Text("0")
                        .font(.title3)
                        .bold()
                    
                    Text("Calories")
                }
                .frame(maxWidth: .infinity)
                
                VStack{
                    Text("0f")
                        .font(.title3)
                        .bold()
                    
                    Text("Elevation")
                }
                .frame(maxWidth: .infinity)

                
                VStack{
                    Text("65")
                        .font(.title3)
                        .bold()
                    
                    Text("BPM")
                }
                .frame(maxWidth: .infinity)

            }.padding()
            
            HStack {
                Button {
                    // Stop action
                    withAnimation{
                        runTracker.stopRun()
                    }
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
                    print("stop")
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}
                }))
                
                Spacer()
                
                Button {
                    withAnimation{
                        runTracker.resumeRun()
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding(36)
                        .background(.black)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)


        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    Pause()
}
