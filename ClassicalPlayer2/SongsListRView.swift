//
//  SongsListRView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/26/21.
//

import SwiftUI

struct SongsListRView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @Binding var showingTrackMissing: Bool
    @Binding var songs: [Song]
    var sectionMarkers: [(label: String, id: Int)]
    let columns = [ GridItem(.adaptive(minimum: 300), alignment: .topLeading) ]

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollValue in
                HStack(spacing: 5) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(0..<songs.count, id: \.self) { index in
                                SongView(showingTrackMissing: $showingTrackMissing,
                                         song: songs[index],
                                         width: trackWidth(geo: geometry))
                            }
                        }
                        .onAppear { scrollToPlaying(value: scrollValue) }
                        .onChange(of: songs) { _ in scrollToPlaying(value: scrollValue) }
                    }.frame(maxWidth: .infinity)
                    SectionIndexTitles(proxy: scrollValue, markers: sectionMarkers)
                }
            }
        }
    }

    private func trackWidth(geo: GeometryProxy) -> CGFloat {
        geo.size.width / 2
    }

    private func scrollToPlaying(value scrollValue: ScrollViewProxy) {
        //NSLog("SLRV scrollToPlaying: \(songs.count) songs, playing: \(musicPlayer.nowPlayingItem?.persistentID ?? 0)")
        if let firstIndex = songs.firstIndex(where: { matches(song: $0) } ) {
            //NSLog("songs matched index \(firstIndex)")
            withAnimation {
                scrollValue.scrollTo(firstIndex, anchor: .top)
            }
        }
    }
    
    private func matches(song: Song) -> Bool {
        let songID = fromCoreData(song.persistentID)
        //NSLog("playing: \(musicPlayer.nowPlayingItem?.persistentID ?? 0) song: \(songID)")
        return musicPlayer.nowPlayingItem?.persistentID == songID
    }
}
