//
//  SidebarView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/30/20.
//

import SwiftUI
import MediaPlayer

fileprivate enum Selected: Hashable {
    case pieces
    case albums
    case nowPlaying
    case artists
    case info
    case songs
    case playlists
}

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @State private var selected: Selected? = .pieces

    var body: some View {
        List {
            NavigationLink(destination: PiecesView(sort: .composer),
                           tag: Selected.pieces,
                           selection: $selected) {
                Label("Pieces by composer", systemImage: "music.quarternote.3")
            }
            NavigationLink(destination: AlbumsView(),
                           tag: Selected.albums,
                           selection: $selected) {
                Label("Albums", systemImage: "rectangle.stack")
            }
            NavigationLink(destination: nowPlayingAlbum,
                           tag: Selected.nowPlaying,
                           selection: $selected) {
                Label("Now Playing Album", systemImage: "square.stack")
                    
            }.disabled(MusicPlayer.player.nowPlayingItem == nil)
            NavigationLink(destination: PiecesView(sort: .artist),
                           tag: Selected.artists,
                           selection: $selected) {
                Label("Artists", systemImage: "person.2")
            }
            NavigationLink(destination: InfoView(),
                           tag: Selected.info,
                           selection: $selected) {
                Label("Info", systemImage: "info.circle")
            }
            NavigationLink(destination: SongsView(),
                           tag: Selected.songs,
                           selection: $selected) {
                Label("Songs", systemImage: "music.note")
            }
            NavigationLink(destination: PlaylistsView(),
                           tag: Selected.playlists,
                           selection: $selected) {
                Label("Playlists", systemImage: "music.note.list")
            }
        }.onAppear { selected = .pieces }
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
