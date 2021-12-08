//
//  LoadingView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/16/21.
//

import SwiftUI

struct LoadingView: View {
    @ObservedObject var mediaLibrary = ClassicalMediaLibrary.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Finding composers:")
            ProgressView(value: mediaLibrary.composersProgress, total: 1.0)
                .padding(.bottom, 10)
            Text("Parsing albums, pieces, songs:")
            ProgressView(value: mediaLibrary.albumsProgress, total: 1.0)
                .padding(.bottom, 10)
            Text("Parsing playlists:")
            ProgressView(value: mediaLibrary.playlistsProgress, total: 1.0)
                .padding(.bottom, 10)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color(.systemGray6).opacity(0.9)))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
