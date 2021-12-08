//
//  TracksRView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/23/21.
//

import SwiftUI
import MediaPlayer

/**
 Layout strategy: HGrid with number of rows computed as half the number of tracks.
 The width of each TrackView is computed from the width of the overall view and constrained.
 */
struct TracksRView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var tracks: [MPMediaItem]
    @State private var firstSelectedIndex: Int? = nil
    let columns = [ GridItem(.adaptive(minimum: 300), alignment: .topLeading) ]

    var body: some View {
        if tracks.count > 0 {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollValue in
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(0 ..< tracks.count, id: \.self) { index in
                                TrackView(tracks: tracks,
                                          myIndex: index,
                                          firstSelectedIndex: $firstSelectedIndex,
                                          width: trackWidth(geo: geometry))
                            }
                        }
                        .onAppear() { scrollToPlaying() }
                        .onChange(of: firstSelectedIndex) { _ in scrollOnSelection(value: scrollValue) }
                        .onChange(of: musicPlayer.indexOfNowPlayingItem) { index in
                            scrollOnChange(value: scrollValue, newValue: index)
                        }
                    }
                }
            }
        } else {
            VStack(alignment: .center) {
                Text("The album appears to have no tracks.")
                Text("This probably can be fixed by synchronizing your device.")
            }
            .padding()
        }
    }
    
//    private func makeRows() -> [GridItem] {
//        Array(repeating: GridItem(.flexible(minimum: 75)), count: tracks.count / 2)
//    }

    private func trackWidth(geo: GeometryProxy) -> CGFloat {
        geo.size.width / 2
    }
    
    private func scrollToPlaying() {
        if let playingIndex = tracks.firstIndex(where: {
            musicPlayer.nowPlayingItem?.persistentID == $0.persistentID}) {
            firstSelectedIndex = playingIndex
        }
    }
    
    private func scrollOnSelection(value scrollValue: ScrollViewProxy) {
        if let firstIndex = firstSelectedIndex {
            withAnimation {
                scrollValue.scrollTo(firstIndex, anchor: .top)
            }
        }
    }
    
    private func scrollOnChange(value scrollValue: ScrollViewProxy, newValue index: Int) {
        if let firstIndex = firstSelectedIndex {
            withAnimation {
                scrollValue.scrollTo(firstIndex + index, anchor: .top)
            }
        }
    }
}
