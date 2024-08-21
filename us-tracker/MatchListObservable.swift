//
//  MatchListObservable.swift
//  us-tracker
//
//  Created by Jason Morales on 8/19/24.
//

import Foundation

@Observable
class MatchListObservable {
    var matchList: [String:[Matches]] = [:]
    var matchDetailsList: [Int: MatchDetail] = [:]
    var api = API()
    var direction = 0
    var date = Date.now
    var dateString = ""
    
    init() {
        Task {
            await fetchMatches(date: getDate(direction: 0))
        }
    }
    
    func fetchMatches(date: String) async {
        do {
            let response: MatchListModel = try await api.fetch(url: "https://www.fotmob.com/api/matches?date=" + date)
            
            response.leagues.forEach { league in
                let matches = league.matches.filter { match in
                    teamData[match.away.id] != nil || teamData[match.home.id] != nil
                }
                if matches.count >= 1 {
                    matchList[league.name] = matches
                }
            }
            
            for (_, matches) in matchList {
                for match in matches {
                    matchDetailsList[match.id] = await fetchMatchDetails(id: match.id)
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    func fetchMatchDetails(id: Int) async -> MatchDetail? {
        do {
            let response: MatchDetail = try await api.fetch(url: "https://www.fotmob.com/api/matchDetails?matchId="+String(id))
            return response
        } catch {
            print(error)
        }
        return nil
    }
    
    func getDate(direction: Int) -> String {
        let currentDate = Date()
        let date = Calendar.current.date(byAdding: .day, value: direction, to: currentDate) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let urlDate = dateFormatter.string(from: date)
        dateFormatter.dateStyle = .long
        dateString = dateFormatter.string(from: date)
        self.date = date
        return urlDate
    }
    
    func getPrevious() async {
        if direction < -90 {
            return
        }
        matchList = [:]
        direction -= 1
        await fetchMatches(date: getDate(direction: direction))
    }
    
    func getNext() async {
        if direction > 90 {
            return
        }
        matchList = [:]
        direction += 1
        await fetchMatches(date: getDate(direction: direction))
    }  
    
    func fetchForDate(_ date: Date) async {
        let calendar = Calendar.current
        direction = calendar.dateComponents([.day, .month, .year], from: Date(), to: date).day!
        if direction >= 0 {
            direction += 1
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let urlDate = dateFormatter.string(from: date)
        dateFormatter.dateStyle = .long
        dateString = dateFormatter.string(from: date)
    
        matchList = [:]
        print(direction)
        await fetchMatches(date: urlDate)
    }
}

