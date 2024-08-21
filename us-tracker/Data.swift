//
//  Data.swift
//  us-tracker
//
//  Created by Jason Morales on 8/19/24.
//

import Foundation

let playerData: [Int: String] = [
    952322: "Brenden Aaronson",
    1171008: "Paxten Aaronson",
    729769: "Tyler Adams",
    982677: "Folarin Balogun",
    1159539: "Taylor Booth",
    924431: "Gianluca Busio",
    1173678: "Johnny",
    780418: "Luca de la Torre",
    892816: "Sergino Dest",
    848266: "Weston McKennie",
    924485: "Mark McKenzie",
    1137272: "Yunus Musah",
    1136099: "Kevin Paredes",
    613714: "Jordan Pefok",
    1036401: "Ricardo Pepi",
    688295: "Christian Pulisic",
    1071179: "Giovanni Reyna",
    950829: "Chris Richards",
    662428: "Antonee Robinson",
    848011: "Joshua Sargent",
    959696: "Joseph Scally",
    1126058: "Malik Tillman",
    688271: "Auston Trusty",
    729988: "Matt Turner",
    889536: "Timothy Weah",
    942980: "Richard Ledezma",
    1057433: "Tanner Tessmann",
    848268: "Haji Wright"
]

let teamData: [Int: String] = [
    8463: "Leeds United",
    9908: "FC Utrecht",
    9885: "Juventus",
    10203: "Nottingham Forest",
    8657: "Sheffield United",
    8640: "PSV Eindhoven",
    9788: "Borussia Mönchengladbach",
    9850: "Norwich City",
    8149: "Union Berlin",
    8721: "Wolfsburg",
    9941: "Toulouse",
    9910: "Celta Vigo",
    8603: "Real Betis",
    7881: "Venezia",
    9829: "Monaco",
    8678: "AFC Bournemouth",
    9879: "Fulham",
    9826: "Crystal Palace",
    9789: "Borussia Dortmund",
    8564: "AC Milan",
    8669: "Coventry City"
]

let teamToPlayer: [Int: [Int]] = [
    8463: [952322],
    9908: [1159539, 1171008],
    9885: [848266, 889536],
    10203: [729988],
    8657: [688271],
    8640: [1036401, 892816, 1126058, 942980],
    9788: [959696],
    9850: [848011],
    8149: [613714],
    8721: [1136099],
    9941: [924485],
    9910: [780418],
    8603: [1173678],
    7881: [1057433, 924431],
    9829: [982677],
    8678: [729769],
    9879: [662428],
    9826: [950829],
    9789: [1071179],
    8564: [688295, 1137272],
    8669: [848268]
]



func convertTime(_ timeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    if let utcDate = dateFormatter.date(from: timeString) {
        
        let pstDateFormatter = DateFormatter()
        pstDateFormatter.dateFormat = "HH:mm"
        pstDateFormatter.timeZone = TimeZone.current
        pstDateFormatter.locale = Locale.current
        
        let pstTimeString = pstDateFormatter.string(from: utcDate)
        
        return pstTimeString
    } else {
        print("Failed to parse UTC time string")
        return ""
    }
}

import UserNotifications

func checkNotificationPermission() -> Bool {
    let current = UNUserNotificationCenter.current()
    
    var status = false
    current.getNotificationSettings { permission  in
        if permission.authorizationStatus == .authorized {
            status = true
        }
        if permission.authorizationStatus == .denied{
            status = false
        }
        if permission.authorizationStatus == .notDetermined {
            current.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    status = true
                } else {
                    status = false
                }
            }
            status = false
        } else {
            status = false
        }
        
    }
    return status
}

import SwiftUI

func checkNotificationStatus(_ id: Int, status: Binding<Bool>?) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
        for request in requests {
            if request.identifier == String(id) {
                DispatchQueue.main.async {
                    print("True")
                    status?.wrappedValue = true
                }
            }
        }
    }
}


func scheduleNotification(title: String, matchId: Int, date: Date, time: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    
    let combinedDate = combine(date: date, with: time)
    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: combinedDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    
    let request = UNNotificationRequest(identifier: String(matchId), content: content, trigger: trigger)
    
    let center = UNUserNotificationCenter.current()
    center.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Added")
        }
    }
}

func combine(date: Date, with time: String) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        let timeComponents = time.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 2 else { return date }

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents[0]
        combinedComponents.minute = timeComponents[1]

        return calendar.date(from: combinedComponents) ?? date
    }
