//
//  SidebarView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/30/20.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink(destination: ComposersRView()) {
                Label("Composers", systemImage: "pencil")
            }
            NavigationLink(destination: AlbumsRView()) {
                Label("Albums", systemImage: "rectangle.stack.fill")
            }
            NavigationLink(destination: Text("Artists")) {
                Label("Artists", systemImage: "person.3.fill")
            }
            NavigationLink(destination: Text("Info")) {
                Label("Info", systemImage: "info.circle.fill")
            }
            NavigationLink(destination: Text("Songs")) {
                Label("Songs", systemImage: "music.note")
            }
            NavigationLink(destination: Text("Playlists")) {
                Label("Playlists", systemImage: "music.note.list")
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
