//
//  PiecesView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/16/21.
//

import SwiftUI
import CoreData

/**
 For regular horizontal size class: Pieces for all composers, in grid.
 
 For help on dynamic filtering see:
 https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui
 For help on programmatic scrolling and section titles:
 https://fivestars.blog/code/section-title-index-swiftui.html
 */

struct PiecesView: View, FilterUpdater {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var musicPlayer: MusicPlayer
    @Environment(\.horizontalSizeClass) var size
    private let sectionCount = 15 //a magic number chosen aesthetically.
    var sort: PieceSorts
    @State private var pieces: [Piece] = []
    @State private var sectionMarkers: [(label: String, id: Piece)] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        PiecesListView(pieces: pieces, sectionMarkers: sectionMarkers)
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error Fetching Data"),
                      message: Text(errorMessage))
            }
            .navigationTitle("Pieces by \(sort.fieldName)")
            /**
             If I just stack the TextField with the list, the TextField scrolls off the top of the screen when
             the keyboard appears.
             If I set the TextField as a navbar tool item, SwiftUI throws so many unsatisfied layout constrants
             under the hood that it's unusable.
             */
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading, content: { searchField })
            })
            .onAppear() {
                updateUI(filterText: "", in: viewContext)
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
            let request = piecesFetchRequest(filter: filterText,
                                             sort: sort,
                                             in: context)
            pieces = try viewContext.fetch(request)
            pieces.sort {
                $0.sortField(sort).anarthrousCompare($1.sortField(sort)) == ComparisonResult.orderedAscending            }
            if pieces.count < sectionCount * 2 {
                sectionMarkers = []
                return
            }
            let sectionSize = pieces.count / sectionCount
            sectionMarkers = []
            for i in 0 ..< sectionCount {
                let piece = pieces[i * sectionSize]
                let label = String((piece.sortField(sort)).prefix(6))
                sectionMarkers.append((label: label, id: piece))
            }
        } catch {
            errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(errorMessage)
            showingError = true
        }
    }
}

struct PiecesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        PiecesView(sort: .composer)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}

struct PiecesListView: View {
    let columns = [ GridItem(.adaptive(minimum: 170), alignment: .topLeading) ]
    var pieces: [Piece]
    var sectionMarkers: [(label: String, id: Piece)]

    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(pieces, id: \.self) { piece in
                            NavigationLink(destination: PieceView(piece: piece)) {
                                PieceGridItem(artwork: ClassicalMediaLibrary.artworkFor(album: piece.albumID),
                                              composer: piece.composer ?? "[anon]",
                                              title: piece.title ?? "[sine nomine]",
                                              artist: piece.artist ?? "[anon]")
                            }
                        }
                    }.frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                SectionIndexTitles(proxy: proxy, markers: sectionMarkers)
            }
        }
    }
}

struct PieceGridItem: View {
    var artwork: UIImage
    var composer: String
    var title: String
    var artist: String
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Spacer()
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 170)
                    .cornerRadius(7)
            }.frame(width: 170, height: 170)
            Text(composer)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(artist)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: 170)
        .padding(.vertical)
    }
}

struct PieceGridItem_Previews: PreviewProvider {
    static var previews: some View {
        PieceGridItem(artwork: ClassicalMediaLibrary.defaultImage,
                      composer: "S. Kolb",
                      title: "Piece of Hearbreaking Sublimity Whose Title Is Way Too Long",
                      artist: "Momo Tsipler & His Wienerwald Companions")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
