//
//  CountdownView.swift
//  run-tracker
//
//  Created by Balogun Kayode on 18/03/2025.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var runTracker: RunTracker
    @State var timer: Timer?
    @State var countDown =  3
    
    var body: some View {
        Text("\(countDown)")
            .font(.system(size: 256))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow)
            .onAppear{
                setupCountDown()
            }
    }
    
    func setupCountDown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            if countDown <= 1 {
                timer?.invalidate()
                timer = nil
                runTracker.presentCountDown =  false
                runTracker.startRun()
            } else {
                countDown -= 1
            }
        }
    }
}

#Preview {
    CountdownView()
}
