//
//  SectionsAsTabsView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/30/20.
//

import SwiftUI
import MediaPlayer

struct CompactWidthView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer


    var body: some View {
        TabView {
            ComposersCView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        Text("Composers")
                    }
                }
            AlbumsView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Albums")
                    }
                }
            nowPlayingAlbum
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "square.stack")
                        Text("Now Playing Album")
                    }
                }
            NavigationView {
                PiecesView(sort: .artist)
            }.navigationViewStyle(StackNavigationViewStyle())
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("Artists")
                    }
                }
            InfoView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "info.circle.fill")
                        Text("Info")
                    }
                }
            SongsView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                }
            NavigationView {
                PlaylistsView()
            }.navigationViewStyle(StackNavigationViewStyle())
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                }
        }
    }
    
    private var nowPlayingAlbum: some View {
        
        return Group() {
            if let currentTrack = musicPlayer.nowPlayingItem, let currentAlbum = albumFor(track: currentTrack, in: viewContext) {
                AlbumView(album: currentAlbum)
            } else {
                Text("Nothin' playin'")
            }
        }
    }
}

struct CompactWidthView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        CompactWidthView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDevice("iPhone 11 Pro Max")
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}
