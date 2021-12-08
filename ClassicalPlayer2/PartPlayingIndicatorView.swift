//
//  PlayingIndicatorView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/11/21.
//

import SwiftUI
import Combine

struct PartPlayingIndicatorView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if musicPlayer.playbackState == .playing {
            AnimatingImageView()
        } else {
            Image(colorScheme == .dark ? "bars-light-paused" : "bars-paused")
                .resizable()
                .scaledToFit()
        }
    }
}

struct PlayingIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        PartPlayingIndicatorView()
            .frame(width: 100)
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environmentObject(MusicPlayer())
    }
}

struct AnimatingImageView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var index = 0
    private var darkBars = (1...10).compactMap { UIImage(named: "bars-\($0)") }
    private var lightBars = (1...10).compactMap { UIImage(named: "bars-light-\($0)") }
    private var timer = LoadingTimer()

    var body: some View {
        Image(uiImage: colorScheme == .dark ? lightBars[index] : darkBars[index])
            .resizable()
            .scaledToFit()
            .onReceive(timer.publisher) { _ in
                if index == 9 { index = 0 }
                else { index += 1 }
                }
            .onDisappear { timer.cancel() }
    }
}

class LoadingTimer {

    let publisher = Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
    private var timerCancellable: Cancellable?

    func cancel() {
        timerCancellable?.cancel()
    }
}
