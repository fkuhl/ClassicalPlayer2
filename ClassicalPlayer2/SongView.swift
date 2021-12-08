//
//  SongView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI
import MediaPlayer

/**
 Displays one Song, one track.
 */
struct SongView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.sizeCategory) var sizeCategory
    @Binding var showingTrackMissing: Bool
    var song: Song
    var width: CGFloat
    @State private var albumTapped = false

    var body: some View {
        VStack(alignment: .leading) {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading) {
                    playingIndicator
                    art
                    Button(action: beginPlaying) { trackTitle }
                    HStack {
                        duration
                        Spacer()
                        albumLink
                    }
                }
            } else {
                HStack {
                    playingIndicator
                    art
                    Button(action: beginPlaying) { trackTitle }
                    Spacer()
                    VStack(alignment: .trailing) {
                        duration
                        Spacer()
                        albumLink
                    }
                }
            }
            Divider()
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .frame(maxWidth: width)
    }

    private var playingIndicator: some View {
        PlayingIndicator(
            current: musicPlayer.nowPlayingItem?.persistentID == fromCoreData(song.persistentID))
    }
    
    private var art: some View {
        Image(uiImage: ClassicalMediaLibrary.artworkFor(album: fromCoreData(song.albumID)))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80)
            .cornerRadius(4)
    }
    
    private var duration: some View {
        Text(song.duration ?? "")
            .font(.caption)
            .padding(5)
    }
    
    private var albumLink: some View {
        Group {
            if let album = song.album {
                NavigationLink(destination: AlbumView(album: album), isActive: $albumTapped) {
                    Button(action: { albumTapped = true }) {
                        Label("", systemImage: "rectangle.stack.fill").font(.caption)
                    }
                }
            }
        }
    }
    
    private func beginPlaying() {
        if let track = trackFor(song: song) {
            musicPlayer.stopObserving()
            musicPlayer.setPlayer(item: track, paused: false)
            musicPlayer.startObserving()
        } else {
            NSLog("no track for song \(song.title ?? "[sine nomine]")")
            self.showingTrackMissing = true
        }
    }
    
    private var trackTitle: some View {
        VStack(alignment: .leading) {
            Text(song.composer ?? "[anon]")
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(song.title ?? "[sine nomine]")
                .font(.body)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(song.artist ?? "")
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

//struct SongView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongView()
//    }
//}
