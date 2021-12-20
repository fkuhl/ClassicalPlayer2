//
//  MusicPlayerCView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/7/21.
//

import SwiftUI
import MediaPlayer

struct MusicPlayerCView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @State private var timeElapsed = "0.00"
    @State private var timeRemaining = "0.00"
    @State private var sliderTime: Double = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    @State private var timerActive = true
    @ScaledMetric(relativeTo: .title) var airplaySize: CGFloat = 50

    var body: some View {
        VStack {
            Text(musicPlayer.nowPlayingItem?.title ?? "[nothing playing]")
                .font(.body)
                .lineLimit(2)
                .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                .padding(.top, 5)
            HStack {
                switch musicPlayer.playbackState {
                case .playing:
                    Button(action: pausePlayer) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                    }
                    .padding(.leading, 10)
                    .disabled(musicPlayer.nowPlayingItem == nil)
                default:
                    Button(action: playPlayer) {
                        Image(systemName: "play.fill")
                            .font(.title)
                    }
                    .padding(.leading, 10)
                    .disabled(musicPlayer.nowPlayingItem == nil)
                }
                VStack {
                    Slider(value: $sliderTime,
                           in: sliderRange(),
                           onEditingChanged: sliderEditingChanged)
                        .disabled(musicPlayer.nowPlayingItem == nil)
                    HStack {
                        Text(timeElapsed).font(.caption)
                        Spacer()
                        Text(timeRemaining).font(.caption)
                    }
                }//.padding()
                AirPlayView()
                    .frame(width: airplaySize, height: airplaySize)
            }
        }.padding(.bottom, 5)
        .background(Color(UIColor.systemGray3))
        .onAppear() {
            displayCurrentPlaybackTime()
        }
        .onChange(of: musicPlayer.nowPlayingItem) { value in
            NSLog("nowPlaying changed, title: \(musicPlayer.nowPlayingItem?.title ?? "[sinenomine]")")
            displayCurrentPlaybackTime()
        }
        .onReceive(timer) { time in
            guard timerActive else { return }
            //NSLog("tick \(time)")
            timerDidFire()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            NSLog("will resign active")
            timerActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            NSLog("will enter foreground")
            timerActive = true
        }
    }
    
    private func displayCurrentPlaybackTime() {
        let trackElapsed = MusicPlayer.player.currentPlaybackTime
        timeElapsed = ClassicalMediaLibrary.durationAsString(trackElapsed)
        if let duration = musicPlayer.nowPlayingItem?.playbackDuration {
            timeRemaining = ClassicalMediaLibrary.durationAsString(duration - trackElapsed)
        }
        sliderTime = trackElapsed
    }
    
    private func timerDidFire() {
        // TODO - support seeking
        switch musicPlayer.playbackState {
        case .playing:
            displayCurrentPlaybackTime()
        default:
            break
        }
    }
    
    private func pausePlayer() {
        MusicPlayer.player.pause()
    }
    
    private func playPlayer() {
        MusicPlayer.player.play()
    }
    
    private func sliderEditingChanged(_: Bool) {
        MusicPlayer.player.currentPlaybackTime = TimeInterval(sliderTime)
        displayCurrentPlaybackTime()
    }
    
    private func sliderRange() -> ClosedRange<Double> {
        0.0 ... Double(
         musicPlayer.nowPlayingItem?.playbackDuration ?? 0.0)
    }
}

struct MusicPlayerCView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerCView()
            .frame(width: 500)
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environmentObject(MusicPlayer())
    }
}
