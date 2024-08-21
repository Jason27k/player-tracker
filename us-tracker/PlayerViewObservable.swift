//
//  PlayerViewModel.swift
//  us-tracker
//
//  Created by Jason Morales on 8/16/24.
//

import Foundation

func oneDecimal(_ num: Float) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    
    return formatter.string(from: NSNumber(value: num)) ?? String(num)
}

func tallyEvents(_ events: [MatchEvent]) -> (String, (Bool, Bool, Bool, Bool)) {
    var goalCount = 0
    var assistCount = 0
    var yellowCardCount = 0
    var redCardCount = 0
    for event in events {
        let type = event.type
        if type == "goal" {
            goalCount += 1
        }
        else if type == "assist" {
            assistCount += 1
        }
        else if type == "yellowCard" {
            yellowCardCount += 1
        } else if type == "redCard" {
            redCardCount += 1
        }
    }
    
    var components: [String] = []
    
    if goalCount > 0 {
        components.append("\(goalCount) Goal\(goalCount > 1 ? "s" : "")")
    }
    if assistCount > 0 {
        components.append("\(assistCount) Assist\(assistCount > 1 ? "s" : "")")
    }
    if yellowCardCount > 0 {
        components.append("\(yellowCardCount) Yellow\(yellowCardCount > 1 ? "s" : "")")
        
    }
    if redCardCount > 0 {
        components.append("\(redCardCount) Red\(redCardCount > 1 ? "s" : "")")
    }
    
    return (components.joined(separator: ", "), (goalCount > 0, assistCount > 0, yellowCardCount > 0, redCardCount > 0))
}

enum PlayerPosition {
    case starter
    case sub
    case unavailable
    case notFound
}

func playerDetails(matchDetail: MatchDetail, playerId: Int, home: Bool) -> (Player?, PlayerPosition) {
    if home {
        if let starters = matchDetail.content.lineup2.homeTeam.starters {
            let startersFiltered = starters.filter { $0.id == playerId }
            if !startersFiltered.isEmpty {
                return (startersFiltered[0], PlayerPosition.starter)
            }
        }
        
        if let subs = matchDetail.content.lineup2.homeTeam.subs {
            let subsFiltered = subs.filter { $0.id == playerId }
            if !subsFiltered.isEmpty {
                return (subsFiltered[0], PlayerPosition.sub)
            }
        }
        
        if let unavailable = matchDetail.content.lineup2.homeTeam.unavailable {
            let unavailableFiltered = unavailable.filter { $0.id == playerId }
            if !unavailableFiltered.isEmpty {
                return (unavailableFiltered[0], PlayerPosition.unavailable)
            }
        }
    } else {
        if let starters = matchDetail.content.lineup2.awayTeam.starters {
            let startersFiltered = starters.filter { $0.id == playerId }
            if !startersFiltered.isEmpty {
                return (startersFiltered[0], PlayerPosition.starter)
            }
        }
        
        if let subs = matchDetail.content.lineup2.awayTeam.subs {
            let subsFiltered = subs.filter { $0.id == playerId }
            if !subsFiltered.isEmpty {
                return (subsFiltered[0], PlayerPosition.sub)
            }
        }
        
        if let unavailable = matchDetail.content.lineup2.awayTeam.unavailable {
            let unavailableFiltered = unavailable.filter { $0.id == playerId }
            if !unavailableFiltered.isEmpty {
                return (unavailableFiltered[0], PlayerPosition.unavailable)
            }
        }
    }
    return (nil, PlayerPosition.notFound)
}
