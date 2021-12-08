//
//  PlaylistsListRView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/7/21.
//

import SwiftUI

struct PlaylistsListRView: View {
    var playlists: [Playlist]

    let columns = [ GridItem(.adaptive(minimum: 170), alignment: .topLeading) ]

    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(playlists, id: \.self) { playlist in
                            NavigationLink(destination: PlaylistView(playlist: playlist)) {
                                PlaylistGridItem(artwork: ClassicalMediaLibrary.artworkFor(album: playlist.albumID),
                                                 name: playlist.name ?? "[sine nomine]",
                                                 descriptionText: playlist.descriptionText ?? "",
                                                 authorDisplayName: playlist.authorDisplayName ?? "[anon")
                            }
                        }
                    }.frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct PlaylistGridItem: View {
    var artwork: UIImage
    var name: String
    var descriptionText: String
    var authorDisplayName: String

    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Spacer()
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 170)
                    .cornerRadius(14)
            }.frame(width: 170, height: 170)
            Text(authorDisplayName)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(name)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(descriptionText)
                .font(.caption)
                .lineLimit(3)
                .truncationMode(.tail)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: 170)
    }
}
