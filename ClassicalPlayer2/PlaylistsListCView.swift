//
//  PlaylistsListCView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/6/21.
//

import SwiftUI

struct PlaylistsListCView: View {
    var playlists: [Playlist]
        
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(playlists, id: \.self) { playlist in
                    NavigationLink(destination: PlaylistView(playlist: playlist)) {
                        PlaylistListItem(artwork: ClassicalMediaLibrary.artworkFor(album: playlist.albumID),
                                         name: playlist.name ?? "[sine nomine]",
                                         descriptionText: playlist.descriptionText ?? "",
                                         authorDisplayName: playlist.authorDisplayName ?? "[anon")
                    }
                }
            }
        }
    }
}

//struct PlaylistsListCView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaylistsListCView()
//    }
//}
