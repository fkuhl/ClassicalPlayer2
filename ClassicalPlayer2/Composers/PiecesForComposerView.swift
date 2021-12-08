//
//  PiecesForComposerView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/1/21.
//

import SwiftUI
import CoreData

/**
 For compact size class: Pieces for specified composer.
 */


struct PiecesForComposerCView: View, FilterUpdater {
    @Environment(\.managedObjectContext) var viewContext
    private let sectionCount = 15 //a magic number chosen aesthetically.
    @State private var pieces: [Piece] = []
    @State private var sectionMarkers: [(label: String, id: Piece)] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    let sort = PieceSorts.title
    var composerName: String
    
    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                PiecesForComposerListView(pieces: pieces)
                    .alert(isPresented: $showingError) {
                        Alert(title: Text("Error Fetching Data"),
                              message: Text(errorMessage))
                    }
                    .navigationTitle(composerName)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading, content: { searchField })
                    })
                    .onAppear() {
                        updateUI(filterText: "", in: viewContext)
                    }
                SectionIndexTitles(proxy: proxy, markers: sectionMarkers)
            }
        }
    }
    
    private var searchField: some View {
        SearchField(uiUpdater: self,
                    sortFieldName: sort.fieldName)
    }

    //FilterUpdater protocol
    func updateUI(filterText: String) {
        updateUI(filterText: filterText, in: viewContext)
    }

    private func updateUI(filterText: String, in context: NSManagedObjectContext) {
        do {
            let request = piecesForComposerFetchRequest(filter: filterText,
                                                        composer: composerName,
                                             in: context)
            pieces = try viewContext.fetch(request)
            pieces.sort {$0.sortField(sort).anarthrousCompare($1.sortField(sort)) == ComparisonResult.orderedAscending
            }
            if pieces.count < sectionCount * 2 {
                sectionMarkers = []
                return
            }
            let sectionSize = pieces.count / sectionCount
            sectionMarkers = []
            for i in 0 ..< sectionCount {
                let piece = pieces[i * sectionSize]
                let label = String(piece.sortField(sort).prefix(6))
                sectionMarkers.append((label: label, id: piece))
            }
        } catch {
            errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(errorMessage)
            showingError = true
        }
    }
}

struct PiecesForComposerListView: View {
    var pieces: [Piece]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(pieces, id: \.self) { piece in
                    NavigationLink(destination:
                                    PieceView(piece: piece)) {
                        PieceItemView(title: piece.title ?? "[no title]",
                                      artist: piece.artist,
                                      artwork: ClassicalMediaLibrary.artworkFor(album: piece.albumID))
                    }
                }
            }.frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
}

struct PieceItemView: View {
    var title: String
    var artist: String?
    var artwork: UIImage
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: artwork)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
                .cornerRadius(7)
            Text(title).font(.body)
            if let artistPresent = artist {
                Text(artistPresent)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(width: 200)
        .padding(.bottom, 20)
    }
}

struct PieceItemView_Previews: PreviewProvider {
    static var previews: some View {
        PieceItemView(title: "Amazing Piece",
                      artist: "Momo Tsipler & His Wienerwald Companions",
                      artwork: ClassicalMediaLibrary.defaultImage)
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}

public func piecesForComposerFetchRequest(filter: String,
                                          composer: String,
                               in context: NSManagedObjectContext) -> NSFetchRequest<Piece> {
    let request = NSFetchRequest<Piece>()
    request.entity = NSEntityDescription.entity(forEntityName: "Piece", in: context)
    let titlePredicate = (filter.count > 0) ?
        NSPredicate(format: "title CONTAINS[cd] %@", filter) :
        NSPredicate(format: "title <> %@", "")
    let composerPredicate = NSPredicate(format: "composer = %@", composer)
    request.predicate = NSCompoundPredicate(
        type: .and,
        subpredicates: [titlePredicate, composerPredicate] )
    return request
}
