//
//  Date+Ext.swift
//  running-club-latest
//
//  Created by Balogun Kayode on 24/07/2025.
//

import Foundation

extension Date {
     func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }

    func timeOfDayString() -> String {
        let hour =  Calendar.current.component(.hour, from: self)
        switch hour {
        case 3..<11:
            return "Morning Run"
            case 11..<15:
            return "Lunch Run"
        case 17..<22:
            return "Evening Run"
        default:
            return "Night Run"
            
        }
    }
}
