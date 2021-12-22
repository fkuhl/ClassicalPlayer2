//
//  SidebarView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/30/20.
//

import SwiftUI
import MediaPlayer

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    ///Causes an item to be active when the view is created.
    //@State private var isDefaultItemActive = true

    var body: some View {
        List {
            NavigationLink(destination: PiecesView(sort: .composer)/*,
                           isActive: $isDefaultItemActive*/) {
                Label("Pieces by composer", systemImage: "music.quarternote.3")
            }
            NavigationLink(destination: AlbumsView()) {
                Label("Albums", systemImage: "rectangle.stack")
            }
            NavigationLink(destination: nowPlayingAlbum) {
                Label("Now Playing Album", systemImage: "square.stack")
                    
            }.disabled(MusicPlayer.player.nowPlayingItem == nil)
            NavigationLink(destination: PiecesView(sort: .artist)) {
                Label("Artists", systemImage: "person.2")
            }
            NavigationLink(destination: InfoView()) {
                Label("Info", systemImage: "info.circle")
            }
            NavigationLink(destination: SongsView()) {
                Label("Songs", systemImage: "music.note")
            }
            NavigationLink(destination: PlaylistsView()) {
                Label("Playlists", systemImage: "music.note.list")
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    private var nowPlayingAlbum: some View {
        
        return Group() {
            if let currentTrack = musicPlayer.nowPlayingItem, let currentAlbum = albumFor(track: currentTrack, in: viewContext) {
                AlbumView(album: currentAlbum)
            } else {
                Text("Nothing presently playing")
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static let player = MusicPlayer()
    
    static var previews: some View {
        SidebarView()
            .environmentObject(player)
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
