//
//  AlbumListItem.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/14/21.
//

import SwiftUI

struct AlbumListItem: View {
    @Environment(\.sizeCategory) var sizeCategory
    var artwork: UIImage
    var composer: String
    var title: String
    var artist: String
    var year: Int32
    var genre: String
    var trackCount: Int32
    
    var body: some View {
        VStack(alignment: .leading) {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading) {
                    art(width: 150)
                    textStack
                }
                .padding(.leading)
            } else {
                HStack {
                    art(width: 100)
                    textStack
                    Spacer()
                }
                .padding(.leading)
            }
            Divider().background(Color(UIColor.systemGray))
        }
    }
    
    private func art(width: CGFloat) -> some View {
        Image(uiImage: artwork)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
            .cornerRadius(7)
    }
    
    private var textStack: some View {
        VStack(alignment: .leading) {
            Text(composer)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(artist)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.tail)
            HStack {
                Text(year > 0 ? ("\(year)  •  " + genre) : genre)
                    .font(.caption)
                    .lineLimit(2)
                    .truncationMode(.tail)
                Spacer()
                Text("tracks: \(trackCount)")
                    .font(.caption)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }
}

struct AlbumListItem_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListItem(artwork: ClassicalMediaLibrary.defaultImage,
                      composer: "S. Kolb",
                      title: "Amazing Title that goes on and on and on and on",
                      artist: "Momo Tsipler & His Wienerwald Companions",
                      year: 1932,
                      genre: "Medium Band",
                      trackCount: 13)
            //.padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
