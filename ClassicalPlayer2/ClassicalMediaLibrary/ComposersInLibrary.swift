//
//  ComposersInLibrary.swift
//  ClassicalPlayer
//
//  Created by Frederick Kuhl on 6/25/19.
//  Copyright © 2019 TyndaleSoft LLC. All rights reserved.
//

import Foundation
import MediaPlayer


fileprivate var composersFound = Set<String>()
fileprivate var albumCount = 0

func composersInLibrary() -> [String] {
    return Array(composersFound)
}

func composersCount() -> Int {
    return composersFound.count
}

func getAlbumCount() -> Int {
    return albumCount
}

/**
 Find and store all the composers that occur in songs.
 Side effect: set album count.
 
 */
func findComposers() {
    albumCount = 0
    var albumsSearched = 0
    composersFound = Set<String>()
    let mediaAlbums = MPMediaQuery.albums()
    if let collections = mediaAlbums.collections {
        albumCount = collections.count
        let progressIncrement = Int(max(1, albumCount / 20)) //update progress bar 4 times
        for mediaAlbum in collections {
            let mediaAlbumItems = mediaAlbum.items
            if ClassicalMediaLibrary.loadOnlyFake
                && mediaAlbumItems[0].genre != ClassicalMediaLibrary.fakeGenre { continue }
            for item in mediaAlbumItems {
                if let composer = item.composer {
                    composersFound.insert(composer)
                }
            }
            albumsSearched += 1
            if albumsSearched % progressIncrement == 0 {
                DispatchQueue.main.async {
                    ClassicalMediaLibrary.shared.composersProgress = CGFloat(albumsSearched) / CGFloat(albumCount)
                }
            }
        }
    }
}

/**
 Does the set of previously found composers contain this (possibly partial) composer name?
 
 - Parameter candidate: composer name from song title, e.g., "Brahms"
 
 - Returns: true if the candidate appears somewhere in one of the stored composers, e.g., "Brahms, Johannes".
 */
func composersContains(candidate: String) -> Bool {
    //Deal with the "Strauss (R)" problem
    let parenComponents = candidate.components(separatedBy: "(")
    let refinedCandidate = parenComponents[0].trimmingCharacters(in: .whitespaces)
    for composer in composersFound {
        if composer.range(of: refinedCandidate, options: String.CompareOptions.caseInsensitive) != nil { return true }
    }
    return false
}
