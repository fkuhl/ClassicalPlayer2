//
//  SongsCommon.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/13/21.
//

import SwiftUI
import CoreData
import MediaPlayer

enum SongSorts: CaseIterable {
    case title
    case composer
    case artist
    
    var fieldName: String {
        switch self {
        case .title:
            return "title"
        case .composer:
            return "composer"
        case .artist:
            return "artist"
        }
    }
}

extension Song {
    func sortField(_ sort: SongSorts) -> String {
        switch sort {
        case .title:
            return self.title ?? "[sine nomine]"
        case .composer:
            return self.composer ?? "[anon]"
        case .artist:
            return self.artist ?? ""
        }
    }
}

/**
 I'm using a straight CoreData FetchRequest instead of the automagical SwiftUI version because
 the automagical approach leaves me with no place to create indexes.
 */
func songsFetchRequest(filter: String,
                              sort: SongSorts,
                              in context: NSManagedObjectContext) -> NSFetchRequest<Song> {
    let request = NSFetchRequest<Song>()
    request.entity = NSEntityDescription.entity(forEntityName: "Song",
                                                in: context)
    let predicate = (filter.count > 0) ?
        NSPredicate(format: "\(sort.fieldName) CONTAINS[cd] %@", filter) :
        NSPredicate(format: "\(sort.fieldName) <> %@", "")
    request.predicate = predicate
    return request
}

func trackFor(song: Song) -> MPMediaItem? {
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: fromCoreData(song.persistentID),
                                             forProperty: MPMediaItemPropertyPersistentID)
    query.filterPredicates = Set([ predicate ])
    var trackData: [MPMediaItem] = []
    if let unwrappedCollections = query.collections {
        for collection in unwrappedCollections {
            let possibleItem = collection.items.first
            if let item = possibleItem {
                if item.isPlayable() { trackData.append(item) } //iTunes LPs have nil URLs!!
            }
        }
    }
    return trackData.first
}

func songFor(track: MPMediaItem, in context: NSManagedObjectContext) -> Song? {
    let request = NSFetchRequest<Song>()
    request.entity = NSEntityDescription.entity(forEntityName: "Song",
                                                in: context)
    let predicate = NSPredicate(format: "persistentID = \(toCoreData(track.persistentID))")
    request.predicate = predicate
    do {
        let songs = try context.fetch(request)
        return songs.first
    } catch {
        let errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
        NSLog(errorMessage)
    }
    return nil
}

