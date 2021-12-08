//
//  AlbumView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/22/21.
//

import SwiftUI

struct AlbumView: View {
    @Environment(\.horizontalSizeClass) var size
    var album: Album
    
    var body: some View {
        VStack(alignment: .leading) {
            AlbumListItem(artwork: ClassicalMediaLibrary.artworkFor(album: album.albumID),
                          composer: album.composer ?? "[anonymous]",
                          title: album.title ?? "[]",
                          artist: album.artist ?? "",
                          year: album.year,
                          genre: album.genre ?? "",
                          trackCount: album.trackCount)
            if size == .compact {
                TracksCView(tracks: tracksFor(album:fromCoreData(album.albumID)))
            } else {
                TracksRView(tracks: tracksFor(album: fromCoreData(album.albumID)))
            }
        }
    }
}
