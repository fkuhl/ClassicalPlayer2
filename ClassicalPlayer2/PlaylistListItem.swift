//
//  PlaylistListItem.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/6/21.
//

import SwiftUI

struct PlaylistListItem: View {
    @Environment(\.sizeCategory) var sizeCategory
    var artwork: UIImage
    var name: String
    var descriptionText: String
    var authorDisplayName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading) {
                    art(width: 150)
                    textStack
                }
                .padding(.leading)
                .padding(.bottom, 5)
                .padding(.top, 5)
            } else {
                HStack {
                    art(width: 100)
                    textStack
                    Spacer()
                }
                .padding(.leading)
                .padding(.bottom, 5)
                .padding(.top, 5)
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
            Text(authorDisplayName)
                .font(.caption)
                .lineLimit(2)
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
    }
}

struct PlaylistListItem_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistListItem(artwork: ClassicalMediaLibrary.defaultImage,
                         name: "My Playlist",
                         descriptionText: "My favoritest list",
                         authorDisplayName: "A. Author")
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
