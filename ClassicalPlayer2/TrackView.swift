//
//  TrackView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/22/21.
//

import SwiftUI
import MediaPlayer

/**
 This displays one trtack in an Album. It needs access to the list of tracks (actually, just a partial
 list) so it can fill the player queue.
 */
struct TrackView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var tracks: [MPMediaItem]
    var myIndex: Int
    @Binding var firstSelectedIndex: Int?
    var width: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PlayingIndicator(current:
                                    musicPlayer.nowPlayingItem?.persistentID == tracks[myIndex].persistentID)
                Button(action: beginPlaying) { trackTitle }
                Spacer()
                Text(ClassicalMediaLibrary.durationAsString(tracks[myIndex].playbackDuration))
                    .font(.caption)
                    .padding(5)
            }
            Divider()
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .frame(maxWidth: width)
    }
    
    private func beginPlaying() {
        let playerItems = tracks[myIndex...]
        guard playerItems.count > 0 else {
            NSLog("TrackView.setQueuePlayer had no items")
            return
        }
        musicPlayer.stopObserving()
        musicPlayer.setPlayer(items: Array(playerItems),
                              tableIndex: myIndex,
                              paused: false)
        firstSelectedIndex = myIndex
        musicPlayer.startObserving()
    }
    
    private var trackTitle: some View {
        Text(tracks[myIndex].title ?? "[sine nomine]")
            .font(.body)
            .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            .truncationMode(.middle)
    }
}
