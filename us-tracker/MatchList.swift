//
//  MatchList.swift
//  us-tracker
//
//  Created by Jason Morales on 8/19/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct MatchList: View {
    @State var leagueObs = MatchListObservable()
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack {
                    DayHeader(leagueObs: leagueObs)
                    ForEach(Array(leagueObs.matchList.keys), id: \.self) {
                        key in
                        Section {
                            ForEach(leagueObs.matchList[key] ?? [], id: \.id) {
                                match in
                                MatchCardView(match: match, matchDetailsList: leagueObs.matchDetailsList, date: leagueObs.date)
                            }
                        } header: {
                            HStack {
                                Text(key)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
        }
    }
}

struct DayHeader: View {
    @State var leagueObs: MatchListObservable
    @Environment(\.colorScheme) var colorScheme
    @State var showSheet: Bool = false
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -90, to: Date())!
        let endDate = calendar.date(byAdding: .day, value: 90, to: Date())!
        return startDate...endDate
    }
    
    var body: some View {
        HStack {
            Button {
                Task {
                    await leagueObs.getPrevious()
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Button {
                showSheet.toggle()
            } label: {
                Text(leagueObs.dateString)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            .popover(isPresented: $showSheet) {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                showSheet.toggle()
                            }
                        }
                        DatePicker("", selection: $leagueObs.date, in: dateRange, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .presentationCompactAdaptation(.fullScreenCover)
                            .onChange(of: leagueObs.date) { oldValue, newValue in
                                showSheet = false
                                Task {
                                    await leagueObs.fetchForDate(newValue)
                                }
                            }
                        Spacer()
                    }
            }
            Spacer()
            Button {
                Task {
                    await leagueObs.getNext()
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .onAppear {
           let _ = checkNotificationPermission()
        }
    }
}

struct MatchCardView: View {
    var match: Matches
    var matchDetailsList: [Int:MatchDetail]
    var date: Date
    
    var body: some View {
        VStack {
            if let matchDetails = matchDetailsList[match.id] {
                MatchHeader(match: match, matchDetails: matchDetails, date: date)
                PlayersView(match: match, matchDetails: matchDetails)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(25)
        
    }
}

struct PlayersView: View {
    var match: Matches
    var matchDetails: MatchDetail
    
    var body: some View {
        VStack {
            HStack {
                Text("Players to watch:")
                Spacer()
            }
            .padding(.vertical)
            VStack {
                if let players = teamToPlayer[match.home.id] {
                    PlayerCardView(players: players, matchDetails: matchDetails, home: true, started: match.status.started)
                }
            }
            VStack {
                if let players = teamToPlayer[match.away.id] {
                    PlayerCardView(players: players, matchDetails: matchDetails, home: false, started: match.status.started)
                }
            }
        }
    }
}

struct PlayerCardView: View {
    var players: [Int]
    var matchDetails: MatchDetail
    var home: Bool
    var started: Bool
    
    var body: some View {
        ForEach(players, id: \.self) { player in
            if let name = playerData[player] {
                HStack(alignment: .top) {
                    LocalWebPImageView(imageName: name.lowercased().split(separator: " ").joined(), width: 70, height: 70)
                        .background(.black)
                        .clipShape(Circle())
                        .padding(.trailing, 5)
                    VStack {
                        let (player, position) = playerDetails(matchDetail: matchDetails, playerId: player, home: home)
                        if let playerInfo = player {
                            if let rating = playerInfo.performance?.rating {
                                HStack {
                                    Text(name)
                                        .fontWeight(.semibold)
                                    if position == PlayerPosition.starter {
                                        Image(systemName: "person.fill.checkmark")
                                    } else if position == PlayerPosition.sub {
                                        Image(systemName: "person.2.fill")
                                    }
                                    Spacer()
                                }
                                HStack {
                                    HStack {
                                        HStack {
                                            Text("Rating: ")
                                            Text(String(oneDecimal(rating)))
                                                .foregroundStyle(rating > 8 ? .blue : (rating > 7 ? .green : .orange))
                                        }
                                        Text(Image(systemName: "star.fill"))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    if let events = playerInfo.performance?.events {
                                        HStack {
                                            EventView(events: events)
                                            Spacer()
                                        }
                                        .padding(.top, -8)
                                    }
                                }
                            } else {
                                HStack {
                                    Text(name)
                                        .fontWeight(.semibold)
                                    Image(systemName:  "person.fill.xmark")
                                    Spacer()
                                }
                            }
                        } else {
                            HStack {
                                Text(name)
                                    .fontWeight(.semibold)
                                if started {
                                    Image(systemName:  "person.fill.xmark")
                                    
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EventView: View {
    var events: [MatchEvent]
    var body: some View {
        let (str, (goals, assists, yellows, reds)) = tallyEvents(events)
        HStack {
            if goals || assists {
                Image(systemName: "soccerball")
            }
            if yellows {
                Image("yellow")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            if reds {
                Image("red")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            Text(str)
        }
    }
}

struct MatchHeader: View{
    var match: Matches
    var matchDetails: MatchDetail
    var date: Date
    @State var notificationAdded = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(match.home.name) vs \(match.away.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                if match.status.started {
                    if let short = match.status.liveTime?.short {
                        Spacer()
                        Text(short)
                    }
                } else {
                    Spacer()
                    Text(convertTime(match.status.utcTime))
                    if notificationAdded == false {
                        Button {
                            print("Tapped")
                            scheduleNotification(title: "\(match.home.name) vs \(match.away.name) is starting", matchId: match.id, date: date, time: convertTime(match.status.utcTime))
                            checkNotificationStatus(match.id, status: $notificationAdded)
                        } label: {
                            Text(Image(systemName: "plus"))
                        }
                    }
                   
                }
            }
            HStack {
                HStack {
                    WebImage(url: URL(string: matchDetails.header.teams[0].imageUrl)) {
                        image in
                        image.resizable()
                            .frame(width: 60, height: 60)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    WebImage(url: URL(string: matchDetails.header.teams[1].imageUrl)) {
                        image in
                        image.resizable()
                            .frame(width: 60, height: 60)
                    } placeholder: {
                        ProgressView()
                    }
                }
                Spacer()
                if match.status.started {
                    Text(String(match.home.score) + " - " + String(match.away.score))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }.onAppear {
            checkNotificationStatus(match.id, status: $notificationAdded)
        }
    }
}

//#Preview {
//    MatchList()
//}

