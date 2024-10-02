//
//  MatchesModel.swift
//  us-tracker
//
//  Created by Jason Morales on 8/15/24.
//

import Foundation

struct MatchListModel: Decodable {
    let leagues: [League]
}

struct League: Decodable {
    let id: Int
    let name: String
    let matches: [Matches]
}

struct Matches: Decodable {
    let id: Int
    let time: String
    let home: Team
    let away: Team
    let status: Status
}

struct Team: Decodable {
    let id: Int
    let score: Int
    let name: String
}

struct Status: Decodable {
    let started: Bool
    let liveTime: LiveTime?
    let utcTime: String
}

struct LiveTime: Decodable {
    let short: String
}

struct LineUp: Decodable {
    let matchId: Int
    let homeTeam: TeamLineUp
    let awayTeam: TeamLineUp
}

struct TeamLineUp: Decodable {
    let id: Int
    let starters: [Player]?
    let subs: [Player]?
    let unavailable: [Player]?
}

struct Performance: Decodable {
    let rating: Float?
    let substitutionEvents: [SubstitutionEvent]
    let events: [MatchEvent]?
}

struct MatchEvent: Decodable {
    let type: String
}

struct SubstitutionEvent: Decodable {
    let time: Int
    let type: String
    let reason: String
}

struct MatchDetail: Decodable {
    let content: Content
    let header: MatchDetailHeader
}

struct MatchDetailHeader: Decodable {
    let teams: [HeaderTeamInfo]
}

struct HeaderTeamInfo: Decodable {
    let id: Int
    let imageUrl: String
}

struct Content: Decodable {
    let lineup2: LineUp?
}

struct Player: Decodable, Identifiable {
    let id: Int?
    let name: String
    let positionId: Int?
    let usualPlayingPositionId: Int?
    let shirtNumber: String?
    let performance: Performance?
    let unavailability: Unavailability?
}

struct Unavailability: Decodable {
    let type: String
}

