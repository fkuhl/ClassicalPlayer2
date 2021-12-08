//
//  AlbumsCommon.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/13/21.
//

import SwiftUI
import CoreData
import MediaPlayer

enum AlbumSorts: CaseIterable {
    case title
    case composer
    case artist
    case genre
    
    var fieldName: String {
        switch self {
        case .title:
            return "title"
        case .composer:
            return "composer"
        case .artist:
            return "artist"
        case .genre:
            return "genre"
        }
    }
}

extension Album {
    func sortField(_ sort: AlbumSorts) -> String {
        switch sort {
        case .title:
            return self.title ?? "[sine nomine]"
        case .composer:
            return self.composer ?? "[anon]"
        case .artist:
            return self.artist ?? ""
        case .genre:
            return self.genre ?? ""
        }
    }
}

/**
 I'm using a straight CoreData FetchRequest instead of the automagical SwiftUI version because
 the automagical approach leaves me with no place to create indexes.
 */
func albumsFetchRequest(filter: String,
                               sort: AlbumSorts,
                               in context: NSManagedObjectContext) -> NSFetchRequest<Album> {
    let request = NSFetchRequest<Album>()
    request.entity = NSEntityDescription.entity(forEntityName: "Album",
                                                in: context)
    let predicate = (filter.count > 0) ?
        NSPredicate(format: "\(sort.fieldName) CONTAINS[cd] %@", filter) :
        NSPredicate(format: "\(sort.fieldName) <> %@", "")
    request.predicate = predicate
    //Defer sorting because NSFetchReuqest doesn't support anarthrousCompare
//    let sorter = NSSortDescriptor(key: sort.fieldName,
//                                  ascending: true,
//                                  selector: #selector(NSString.localizedCaseInsensitiveCompare))
//    request.sortDescriptors = [ sorter ]
    return request
}

func tracksFor(album: MPMediaEntityPersistentID) -> [MPMediaItem] {
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: album,
                                             forProperty: MPMediaItemPropertyAlbumPersistentID)
    query.filterPredicates = Set([ predicate ])
    var trackData: [MPMediaItem] = []
    if let unwrappedCollections = query.collections {
        for collection in unwrappedCollections {
            let possibleItem = collection.items.first
            if let item = possibleItem {
                //if item.assetURL != nil { trackData?.append(item) } //iTunes LPs have nil URLs!!
                if item.isPlayable() { trackData.append(item) } //iTunes LPs have nil URLs!!
            }
        }
    }
    return trackData
}

func albumFor(track: MPMediaItem,
              in context: NSManagedObjectContext) -> Album? {
    let request = NSFetchRequest<Album>()
    request.entity = NSEntityDescription.entity(forEntityName: "Album",
                                                in: context)
    request.predicate = NSPredicate(format: "albumID = \(track.albumPersistentID)")
    do {
        let albums = try context.fetch(request)
        return albums.first
    } catch {
        let errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
        NSLog(errorMessage)
    }
    return nil
}
