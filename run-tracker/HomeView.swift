//
//  HomeView.swift
//  run-tracker
//
//  Created by Balogun Kayode on 18/03/2025.
//

import SwiftUI
import MapKit

struct AreaMap: View {
    @Binding var region: MKCoordinateRegion
    var body: some View {
        let binding = Binding(
            get: {self.region},
            set:{newValue in
                DispatchQueue.main.async {
                    self.region = newValue
                }
            }
        )
        return Map(coordinateRegion: binding, showsUserLocation: true).ignoresSafeArea()
    }
}

struct HomeView: View {
    @StateObject var runTracker = RunTracker()
    
    var body: some View {
        NavigationStack{
            VStack {
                ZStack(alignment: .bottom) {
                    AreaMap(region: $runTracker.region)
                    
                    Button {
                        runTracker.presentCountDown =  true
                    } label: {
                        Text("Start")
                            .bold()
                            .font(.title)
                            .foregroundStyle(.black)
                            .padding(36)
                            .background(.yellow)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 40)

                }
            }.navigationTitle("Run")
                .frame(maxHeight: .infinity, alignment: .top)
                .fullScreenCover(isPresented: $runTracker.presentCountDown, content: {
                    CountdownView()
                        .environmentObject(runTracker)
                })
                .fullScreenCover(isPresented: $runTracker.presentRunView, content: {
                    RunView().environmentObject(runTracker)
                })
                .fullScreenCover(isPresented: $runTracker.presentPauseView, content: {
                    Pause().environmentObject(runTracker)
                })

        }
    }
}

#Preview {
    HomeView()
}
