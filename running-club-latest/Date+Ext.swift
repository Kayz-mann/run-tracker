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

}
