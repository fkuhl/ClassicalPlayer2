//
//  ComposersView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/29/20.
//

import SwiftUI
import CoreData

/**
 For compact horizontal size class.
 The difference between this and the regular version, ComposersRView, is in navigation.
 This ComposersView uses a NavigationView, so pushes PiecesForComposerView on its nav stack.
 
 For help on dynamic filtering see:
 https://www.hackingwithswift.com/books/ios-swiftui/dynamically-filtering-fetchrequest-with-swiftui
 For help on programmatic scrolling and section titles:
 https://fivestars.blog/code/section-title-index-swiftui.html
 */

struct ComposersCView: View, FilterUpdater {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    private let sectionCount = 15 //a magic number chosen aesthetically.
    @State private var composers: [Composer] = []
    @State private var sectionMarkers: [(label: String, id: Composer)] = []
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ComposersListCView(composers: composers,
                               sectionMarkers: sectionMarkers,
                               showingError: $showingError,
                               errorMessage: $errorMessage)
                .alert(isPresented: $showingError) {
                    Alert(title: Text("Error Fetching Data"),
                          message: Text(errorMessage))
                }
            .navigationTitle("Composers")
            /**
             If I just stack the TextField with the list, the TextField scrolls off the top of the screen when
             the keyboard appears.
             If I set the TextField as a navbar tool item, SwiftUI throws so many unsatisfied layout constrants
             under the hood that it's unusable.
             */
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading, content: { searchField })
            })
            .onAppear() { updateUI(filterText: "", in: viewContext) }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var searchField: some View {
        SearchField(uiUpdater: self,
                    sortFieldName: "name")
    }

    //FilterUpdater protocol
    func updateUI(filterText: String) {
        updateUI(filterText: filterText, in: viewContext)
    }

    /**
     Identical to func of same name in ComposersCView.
     But this is so tightly bound to this scope that pulling it out
    would be a mess.
     */
    private func updateUI(filterText: String, in context: NSManagedObjectContext) {
        do {
            let request = composersFetchRequest(filter: filterText, in: context)
            composers = try viewContext.fetch(request)
            if composers.count < sectionCount * 2 {
                sectionMarkers = []
                return
            }
            let sectionSize = composers.count / sectionCount
            sectionMarkers = []
            for i in 0 ..< sectionCount {
                let composer = composers[i * sectionSize]
                let label = String((composer.name ?? "[no name]").prefix(3))
                sectionMarkers.append((label: label, id: composer))
            }
        } catch {
            errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(errorMessage)
            showingError = true
        }
    }
}

struct ComposersCView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        ComposersCView()
            .previewLayout(.fixed(width: 896, height: 414))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .compact)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}

struct ComposersListCView: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass) var verticalSize
    var composers: [Composer]
    var sectionMarkers: [(label: String, id: Composer)]
    @Binding var showingError: Bool
    @Binding var errorMessage: String

    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: 5) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(composers, id: \.self) { composer in
                            ComposersCompactLink(composer: composer,
                                                 showingError: $showingError,
                                                 errorMessage: $errorMessage)
                        }
                    }
                }
                if verticalSize == .regular {
                    SectionIndexTitles(proxy: proxy, markers: sectionMarkers)
                }
            }

        }
    }
}

struct ComposersCompactLink: View {
    var composer: Composer
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: PiecesForComposerCView(
                    composerName: composer.name ?? "[anon]")) {
                Text(composer.name ?? "Unk")
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(5)
            }
        }
    }
    
    func piecesForComposer(composer: String) -> [Piece] {
        let viewContext = PersistenceController.shared.container.viewContext
        var pieces: [Piece] = []
        do {
            let request = NSFetchRequest<Piece>()
            request.entity = NSEntityDescription.entity(forEntityName: "Piece",
                                                        in: viewContext)
            request.predicate = NSPredicate(format: "%K == %@", "composer", composer)
            request.resultType = .managedObjectResultType
            request.returnsDistinctResults = true
            pieces = try viewContext.fetch(request)
            pieces.sort(by: anarthrousTitlePredicate)
        } catch {
            let message = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(message)
            errorMessage = message
            showingError = true
        }
        return pieces
    }
}
