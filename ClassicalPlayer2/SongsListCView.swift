//
//  SongsListCView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI

struct SongsListCView: View {
    @Environment(\.verticalSizeClass) var verticallSize
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @Binding var showingTrackMissing: Bool
    @Binding var songs: [Song]
    var sectionMarkers: [(label: String, id: Int)]

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollValue in
                HStack(spacing: 5) {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                                ForEach(0..<songs.count, id: \.self) { index in
                                    SongView(showingTrackMissing: $showingTrackMissing,
                                             song: songs[index],
                                             width: geometry.size.width)
                            }
                        }
                        .onAppear() { scrollToPlaying(value: scrollValue) }
                        .onChange(of: songs) { _ in scrollToPlaying(value: scrollValue) }
                    }
                    if verticallSize == .regular {
                        SectionIndexTitles(proxy: scrollValue, markers: sectionMarkers)
                    }
                }
            }
        }
    }
    
    private func scrollToPlaying(value scrollValue: ScrollViewProxy) {
        NSLog("SLCV scrollToPlaying: \(songs.count) songs, playing: \(musicPlayer.nowPlayingItem?.persistentID ?? 0)")
        if let firstIndex = songs.firstIndex(where: { matches(song: $0) } ) {
            NSLog("songs matched index \(firstIndex)")
            withAnimation {
                scrollValue.scrollTo(firstIndex, anchor: .top)
            }
        }
     }
    
    private func matches(song: Song) -> Bool {
        let songID = fromCoreData(song.persistentID)
        return musicPlayer.nowPlayingItem?.persistentID == songID
    }
}

