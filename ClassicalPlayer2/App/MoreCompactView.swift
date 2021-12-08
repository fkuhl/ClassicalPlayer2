//
//  MoreCompactView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/7/21.
//

import SwiftUI

/**
 So why is this here? Because TabView in SwiftUI doesn't work properly for >5 items.
 The navigation on the "more" items jumps back to tag 0. Or so it appears.
 With this view shown by the (now manual) "more", the navigation is correct.
 Of course, you wind up with two stacked sets of tabls, which looks really stupid.
 */

struct MoreCompactView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            InfoView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "info.circle.fill")
                        Text("Info")
                    }
                }
                .tag(4)
            SongsView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                }
                .tag(5)
            PlaylistsView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                }
                .tag(6)
        }
    }
}

struct MoreCompactView_Previews: PreviewProvider {
    static var previews: some View {
        MoreCompactView()
    }
}
