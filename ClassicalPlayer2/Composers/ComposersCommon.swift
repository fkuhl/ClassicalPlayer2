//
//  ComposersCommon.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/5/21.
//

import SwiftUI
import CoreData


public enum PieceSorts: CaseIterable {
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

extension Piece {
    func sortField(_ sort: PieceSorts) -> String {
        switch sort {
        case .title:
            return self.title ?? "[sine nom.]"
        case .composer:
            return self.composer ?? "[anon]"
        case .artist:
            return self.artist ?? ""
        }
    }
}

struct SectionIndexTitles<ListType: Hashable>: View {
    let proxy: ScrollViewProxy
    let markers: [(label: String, id: ListType)]
    
    var body: some View {
        VStack {
            ForEach(markers, id: \.id) { marker in
                SectionIndexTitle<ListType>(proxy: proxy, marker: marker)
            }
        }
    }
}

struct SectionIndexTitle<ListType: Hashable>: View {
    let proxy: ScrollViewProxy
    let marker: (label: String, id: ListType)
    
    var body: some View {
        Button(action: {
            NSLog("scrolling to \(marker.label)")
            withAnimation {
                proxy.scrollTo(marker.id, anchor: .top)
            }
        }) {
            Text(marker.label).font(.footnote)
        }
        .padding(5)
        .background(Color.gray.opacity(0.1))
    }
}


/**
 I'm using a straight CoreData FetchRequest instead of the automagical SwiftUI version because
 the automagical approach leaves me with no place to create indexes.
 */
public func composersFetchRequest(filter: String, in context: NSManagedObjectContext) -> NSFetchRequest<Composer> {
    let request = NSFetchRequest<Composer>()
    request.entity = NSEntityDescription.entity(forEntityName: "Composer", in: context)
    let predicate = (filter.count > 0) ?
        NSPredicate(format: "name CONTAINS[cd] %@", filter) :
        NSPredicate(format: "name <> %@", "")
    request.predicate = predicate
    let sorter = NSSortDescriptor(key: "name",
                                  ascending: true,
                                  selector: #selector(NSString.localizedCaseInsensitiveCompare))
    request.sortDescriptors = [ sorter ]
    return request
}

public func piecesFetchRequest(filter: String,
                               sort: PieceSorts,
                               in context: NSManagedObjectContext) -> NSFetchRequest<Piece> {
    let request = NSFetchRequest<Piece>()
    request.entity = NSEntityDescription.entity(forEntityName: "Piece", in: context)
    let predicate = (filter.count > 0) ?
        NSPredicate(format: "\(sort.fieldName) CONTAINS[cd] %@", filter) :
        NSPredicate(format: "\(sort.fieldName) <> %@", "")
    request.predicate = predicate
//    let byComposer = NSSortDescriptor(key: "composer",
//                                  ascending: true,
//                                  selector: #selector(NSString.localizedCaseInsensitiveCompare))
//    let byTitle = NSSortDescriptor(key: "title",
//                                  ascending: true,
//                                  selector: #selector(NSString.localizedCaseInsensitiveCompare))
//    request.sortDescriptors = [ byComposer, byTitle ]
    return request
}
