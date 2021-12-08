//
//  AlbumsListCView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI


struct AlbumsListCView: View {
//    @Environment(\.horizontalSizeClass) var size
    var albums: [Album]
    var sectionMarkers: [(label: String, id: Album)]

    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(albums, id: \.self) { album in
                            NavigationLink(destination: AlbumView(album: album)) {
                                AlbumListItem(artwork: ClassicalMediaLibrary.artworkFor(album: album.albumID),
                                              composer: album.composer ?? "[anon]",
                                              title: album.title ?? "[sine nomine]",
                                              artist: album.artist ?? "[anon]",
                                              year: album.year,
                                              genre: album.genre ?? "[]",
                                              trackCount: album.trackCount)
                            }
                        }
                    }
                }
                SectionIndexTitles(proxy: proxy, markers: sectionMarkers)
            }
        }
    }
}

//
//struct AlbumsListCView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumsListCView()
//    }
//}
