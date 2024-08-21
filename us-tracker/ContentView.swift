//
//  ContentView.swift
//  us-tracker
//
//  Created by Jason Morales on 8/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectionIndex = 0
    var body: some View {
        MatchList()
    }
}

#Preview {
    ContentView()
}
