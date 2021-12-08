//
//  SongsView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI
import CoreData

/**
 Songs in both horizontal size classes.
 */

struct SongsView: View, FilterUpdater {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @Environment(\.horizontalSizeClass) var size
    private let sectionCount = 15 //a magic number chosen aesthetically.
    @State private var sort: SongSorts = .title
    @State private var songs: [Song] = []
    @State private var sectionMarkers: [(label: String, id: Int)] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingTrackMissing = false
    @State private var showingProgress = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                if size == .compact {
                    cList
                } else {
                    rGrid
                }
            }
            if showingProgress {
                ProgressView().scaleEffect(3.0, anchor: .center)
            }
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error Fetching Data"),
                  message: Text(errorMessage))
        }
        .alert(isPresented: $showingTrackMissing) { trackMissingAlert() }
        .onAppear() { updateUI(filterText: "") }
        .onChange(of: self.sort) { _ in  updateUI(filterText: "") }
    }
    
    private var cList: some View {
        NavigationView {
            SongsListCView(showingTrackMissing: $showingTrackMissing,
                           songs: $songs, sectionMarkers: sectionMarkers)
                .navigationTitle("Songs by \(sort.fieldName)")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) { searchField }
                    ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var rGrid: some View {
        SongsListRView(showingTrackMissing: $showingTrackMissing,
                       songs: $songs,
                       sectionMarkers: sectionMarkers)
            .navigationTitle("Songs by \(sort.fieldName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) { searchField }
                ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
            })
    }
    
    private var searchField: some View {
        SearchField(uiUpdater: self,
                    sortFieldName: sort.fieldName)
    }
    
    private func trackMissingAlert() -> Alert {
        let button = Alert.Button.default(Text("Got it.")) {  }
        return Alert(title: Text("Missing Media"),
                     message: Text("This track does not have media. This probably can be fixed by synchronizing your device."),
                     dismissButton: button)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SongSorts.allCases, id: \.self) { sort in
                Button(action: {
                    self.sort = sort
                }) {
                    Text(sort.fieldName)
                }
            }
        }
        label: {
            Label("", systemImage: "arrow.up.arrow.down").font(.caption)
        }
    }
    
    //FilterUpdater protocol
    func updateUI(filterText: String) {
        showingProgress = true
        ///On background thread because the anarthrous sort takes a while for large numbers
        PersistenceController.shared.container.performBackgroundTask() { context in
            do {
                let request = songsFetchRequest(filter: filterText, sort: sort, in: context)
                var songs = try viewContext.fetch(request)
                /**
                 We're sorting here rather than in the FetchRequest because the FetchRequest does not support our anarthrousCompare.
                 */
                songs.sort {
                    $0.sortField(sort).anarthrousCompare($1.sortField(sort)) == ComparisonResult.orderedAscending
                }
                if songs.count < sectionCount * 2 {
                    DispatchQueue.main.async {
                        showingProgress = false
                        self.songs = songs
                        self.sectionMarkers = []
                    }
                    return
                }
                let sectionSize = songs.count / sectionCount
                var sectionMarkers: [(label: String, id: Int)] = []
                for i in 0 ..< sectionCount {
                    let song = songs[i * sectionSize]
                    let label = String((song.sortField(sort)).prefix(3))
                    sectionMarkers.append((label: label, id: i * sectionSize))
                }
                DispatchQueue.main.async {
                    showingProgress = false
                    self.songs = songs
                    self.sectionMarkers = sectionMarkers
                }
            } catch {
                DispatchQueue.main.async {
                    showingProgress = false
                    errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
                    NSLog(errorMessage)
                    showingError = true
                }
            }
        }
    }
}

struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        SongsView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))

        SongsView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
    }
}
