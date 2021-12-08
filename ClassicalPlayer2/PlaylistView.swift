//
//  PlaylistView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/7/21.
//

import SwiftUI

struct PlaylistView: View {
    @Environment(\.horizontalSizeClass) var size
    var playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading) {
            PlaylistListItem(artwork: ClassicalMediaLibrary.artworkFor(album: playlist.albumID),
                             name: playlist.name ?? "[sine nomine]",
                             descriptionText: playlist.descriptionText ?? "",
                             authorDisplayName: playlist.authorDisplayName ?? "[anon")
            if size == .compact {
                TracksCView(tracks: tracksFor(playlist: playlist))
            } else {
                TracksRView(tracks: tracksFor(playlist: playlist))
            }
        }
    }
}
