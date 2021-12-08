//
//  MusicPlayer.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/6/21.
//

import SwiftUI
import Combine
import MediaPlayer

public class MusicPlayer: ObservableObject {
    @Published var isActive: Bool = false
    @Published var nowPlayingItem: MPMediaItem? = nil
    @Published var indexOfNowPlayingItem: Int = 0
    @Published var playbackState: MPMusicPlaybackState = .stopped
    
    #if targetEnvironment(macCatalyst)
    //The hope was that on Mac the system player would work. Doesn't, consistently.
    public static var player = MPMusicPlayerController.systemMusicPlayer
    #else
    public static var player = MPMusicPlayerController.systemMusicPlayer
    #endif
    /**
     Note to self: If you don't store the subscriber when you make it, the Notifications go into the ether.
     */
    private var nowPlayingSubscriber: AnyCancellable?
    private var playbackStateSubscriber: AnyCancellable?
    private var isObserving = false
    
    /**
     Called from quasi app delegate to ensure MusicPlayer reflects system state
     */
    func initializeFromPlayer() {
        isActive = Self.player.nowPlayingItem != nil
        nowPlayingItem = Self.player.nowPlayingItem
        indexOfNowPlayingItem = Self.player.indexOfNowPlayingItem
        playbackState = Self.player.playbackState
        if isActive { startObserving() }
    }

    func startObserving() {
        if isObserving {
            NSLog("MusicPlayer \(#function) already observing!")
        }
        nowPlayingSubscriber = nowPlayingItemChangedPublisher()
            .receive(on: RunLoop.main)
            .sink{ _ in
                NSLog("MP nowPlaying: \(Self.player.nowPlayingItem?.title ?? "<none>") index: \(musicPlayerIndexOfNowPlayingItem())")
                self.nowPlayingItem = Self.player.nowPlayingItem
                self.indexOfNowPlayingItem = Self.player.indexOfNowPlayingItem
            }
        playbackStateSubscriber = playbackStateChangedPublisher()
            .receive(on: RunLoop.main)
            .sink{ _ in
                NSLog("MP playback state changed to \(playbackStateAsString(to: self.playbackState))")
                self.playbackState = Self.player.playbackState
            }
        Self.player.beginGeneratingPlaybackNotifications()
        isObserving = true
        NSLog("MusicPlayer \(#function)")
    }
    
    func stopObserving() {
        if isObserving {
            Self.player.endGeneratingPlaybackNotifications()
            nowPlayingSubscriber?.cancel()
            playbackStateSubscriber?.cancel()
            isObserving = false
        }
    }


    /**
     The case where one track is to be played, not from a table.
     */
    func setPlayer(item: MPMediaItem, paused: Bool) {
        NSLog("MusicPlayer.setPlayer, item: '\(item.title ?? "<sine nomine>")', paused: \(paused)")
        var items = [MPMediaItem]()
        items.append(item)
        setQueueAndPrepareToPlay(items: items, paused: paused)
        withAnimation {
            isActive = true
        }
    }

    /**
    The case where one or more tracks are to be played from a table.
     */
    func setPlayer(items: [MPMediaItem], tableIndex: Int, paused: Bool) {
        NSLog("MusicPlayer.setPlayer, \(items.count) items, tableIndex: \(tableIndex), paused: \(paused)")
        setQueueAndPrepareToPlay(items: items, paused: paused)
        withAnimation {
            isActive = true
        }
    }
    
    private func setQueueAndPrepareToPlay(items: [MPMediaItem], paused: Bool) {
        guard items.count > 0 else {
            NSLog("setQueueAndPrepareToPlay called with empty item list")
            return
        }
        Self.player.pause()
        Self.player.shuffleMode = .off
//        let dGroup = DispatchGroup()
//        dGroup.enter()
//        Self.player.setQueue(with: MPMediaItemCollection(items: items))
//        Self.player.prepareToPlay() {
//            (inError: Error?) in
//            if let error = inError {
//                NSLog("MusicPlayer prepareToPlay completion error: \(error), \(error.localizedDescription)")
//            } else {
//                if paused {
//                    Self.player.pause()
//                } else {
//                    Self.player.play()
//                }
//            }
//            dGroup.leave()
//        }
        Self.player.setQueue(with: MPMediaItemCollection(items: items))
                if paused {
                    Self.player.pause()
                } else {
                    Self.player.play()
                }
    }
}

func musicPlayerPlaybackState() -> MPMusicPlaybackState {
    return MusicPlayer.player.playbackState
}

func musicPlayerIndexOfNowPlayingItem() -> Int {
    return MusicPlayer.player.indexOfNowPlayingItem
}

func playbackStateAsString(to: MPMusicPlaybackState) -> String {
    let state: String
    switch (musicPlayerPlaybackState()) {
    case .stopped:
        state = "stopped"
    case .playing:
        state = "playing"
    case .paused:
        state = "paused"
    case .interrupted:
        state = "interrupted"
    case .seekingForward:
        state = "seeking forward"
    case .seekingBackward:
        state = "seeking backward"
    @unknown default:
        fatalError("playbackStateAsString MPMusicPlaybackState unknown enum value")
    }
    return state
}

/**
 Why not use AVAudioPlayer rather tha MPMusicPlayer? I tried AVAudioPlayer(contentsOf: item.assetURL)
 and the app gets Error Domain=NSOSStatusErrorDomain Code=-54 "permErr: permissions error (on file open)"
 
 See:
 https://developer.apple.com/forums/thread/96062
 
 Sandboxed apps cannot read files from outside the sandbox, except where explicitly given permission by the user via an Open File dialog, which returns a "security scoped URL".

 You can turn off sandboxing by selecting the project item in the navigator pane, and choosing the Entitlements tab of the project editor. This is OK to do, but it means you can't distribute the app through the Mac App Store. (It should still be code-signed, though, for ad-hoc distribution, to avoid being blocked by GateKeeper.)

 Or, you can let your app be sandboxed, and use NSOpenPanel to get permission from the user. In this case, you can save a security scoped bookmark from the URL that can be re-consistituted the next time the app launches, so you only need to get permission once.

 Or, if the file you're trying to read, you can arrange to place it inside the sandbox somewhere (such as the Application Support folder, if not you app bundle), so permissions are not an issue.

 Finally, all modern Mac apps should not use path-based APIs except in extremely unusual circumstances. URL-based APIs are always preserved. (One reason: there are no security-scoped paths, only URLs.)
 */
