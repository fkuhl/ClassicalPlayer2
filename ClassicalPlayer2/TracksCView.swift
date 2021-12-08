//
//  TracksRView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/23/21.
//

import SwiftUI
import MediaPlayer

struct TracksCView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var tracks: [MPMediaItem]
    @State private var firstSelectedIndex: Int? = nil
    
    var body: some View {
        if tracks.count > 0 {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollValue in
                        LazyVStack(alignment: .leading) {
                            ForEach(0..<tracks.count, id: \.self) { index in
                                TrackView(tracks: tracks,
                                          myIndex: index,
                                          firstSelectedIndex: $firstSelectedIndex,
                                          width: geometry.size.width)
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
    
    private func scrollToPlaying() {
        if let playingIndex = tracks.firstIndex(where: {
            musicPlayer.nowPlayingItem?.persistentID == $0.persistentID}) {
            firstSelectedIndex = playingIndex
            // ...and the change of value triggers scrollOnSelection
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
