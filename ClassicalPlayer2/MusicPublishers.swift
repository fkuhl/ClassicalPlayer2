//
//  MusicPublishers.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/6/21.
//

import SwiftUI
import Combine
import MediaPlayer


func nowPlayingItemChangedPublisher() -> AnyPublisher<MPMediaItem, Never> {
    NotificationCenter.default
        .publisher(for: .MPMusicPlayerControllerNowPlayingItemDidChange)
        .compactMap { _ in MusicPlayer.player.nowPlayingItem }
        .eraseToAnyPublisher()
}

func playbackStateChangedPublisher() -> AnyPublisher<MPMusicPlaybackState, Never> {
    NotificationCenter.default
        .publisher(for: .MPMusicPlayerControllerPlaybackStateDidChange)
        .compactMap { _ in MusicPlayer.player.playbackState }
        .eraseToAnyPublisher()
}
