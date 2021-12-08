//
//  PlayingIndicator.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/19/21.
//

import SwiftUI
import MediaPlayer

struct PlayingIndicator: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var current: Bool

    var body: some View {
        if current {
            PartPlayingIndicatorView()
                .frame(width: 20, height: 20)
                .padding(5)
        } else {
            Image("bars-not-current")
                .frame(width: 20, height: 20)
                .padding(5)
        }
    }
}

//struct PlayingIndicator_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayingIndicator()
//    }
//}
