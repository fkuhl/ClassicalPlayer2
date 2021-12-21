//
//  AlbumsListRView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI

struct AlbumsListRView: View {
    @Environment(\.verticalSizeClass) var verticalSize
    var albums: [Album]
    var sectionMarkers: [(label: String, id: Album)]

    let columns = [ GridItem(.adaptive(minimum: 170), alignment: .topLeading) ]

    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(albums, id: \.self) { album in
                            NavigationLink(destination: AlbumView(album: album)) {
                                AlbumGridItem(artwork: ClassicalMediaLibrary.artworkFor(album: album.albumID),
                                              composer: album.composer ?? "[anon]",
                                              title: album.title ?? "[sine nomine]",
                                              artist: album.artist ?? "[anon]")
                            }
                        }
                    }.frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                if verticalSize == .regular {
                    SectionIndexTitles(proxy: proxy, markers: sectionMarkers)
                }
            }
        }
    }
}

struct AlbumGridItem: View {
    var artwork: UIImage
    var composer: String
    var title: String
    var artist: String
    
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
            Text(composer)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(artist)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: 170)
    }
}

struct AlbumGridItem_Previews: PreviewProvider {
    static var previews: some View {
        AlbumGridItem(artwork: ClassicalMediaLibrary.defaultImage,
                      composer: "S. Kolb",
                      title: "Amazing Album Whose Title Is Way Too Long",
                      artist: "Momo Tsipler & His Wienerwald Companions")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
