//
//  PlaylistsCommon.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/6/21.
//

import SwiftUI
import CoreData
import MediaPlayer

/**
 Could probably use the automagical SwiftUI  fetch request, but we're copying
 and modifying from Albums (with no sorting)
 */

func playlistsFetchRequest(filter: String,
                               in context: NSManagedObjectContext) -> NSFetchRequest<Playlist> {
    let request = NSFetchRequest<Playlist>()
    request.entity = NSEntityDescription.entity(forEntityName: "Playlist",
                                                in: context)
    let predicate = (filter.count > 0) ?
        NSPredicate(format: "name CONTAINS[cd] %@", filter) :
        NSPredicate(format: "name <> %@", "")
    request.predicate = predicate
    //Defer sorting because NSFetchReuqest doesn't support anarthrousCompare
    return request
}

func tracksFor(playlist: Playlist) -> [MPMediaItem] {
    return playlist.songs?.compactMap { song in trackFor(song: song as! Song) } ?? []
}

