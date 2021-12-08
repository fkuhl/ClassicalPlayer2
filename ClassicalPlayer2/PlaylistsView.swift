//
//  PlaylistsView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 10/6/21.
//

import SwiftUI
import CoreData

struct PlaylistsView: View, FilterUpdater {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var size
    @State private var playlists: [Playlist] = []
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        Group {
            if size == .compact {
                cList
            } else {
                rGrid
            }
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error Fetching Data"),
                  message: Text(errorMessage))
        }
        .onAppear() { updateUI(filterText: "", in: viewContext) }
    }
    
    private var cList: some View {
        PlaylistsListCView(playlists: playlists)
            .navigationTitle("Playlists by name")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) { searchField }
            })
    }

    private var rGrid: some View {
        PlaylistsListRView(playlists: playlists)
            .navigationTitle("Playlists by name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) { searchField }
            })
    }
    
    private var searchField: some View {
        SearchField(uiUpdater: self,
                    sortFieldName: "title")
    }

    //FilterUpdater protocol
    func updateUI(filterText: String) {
        updateUI(filterText: filterText, in: viewContext)
    }
    
    private func updateUI(filterText: String, in context: NSManagedObjectContext) {
        do {
            let request = playlistsFetchRequest(filter: filterText, in: context)
            playlists = try viewContext.fetch(request)
            /**
             We're sorting here rather than in the FetchRequest because the FetchRequest does not support
             our anarthrousCompare.
             */
            playlists.sort {
                ($0.name ?? "").anarthrousCompare(($1.name ?? "")) == ComparisonResult.orderedAscending
            }
        } catch {
            errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(errorMessage)
            showingError = true
        }
    }
}

struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistsView()
    }
}
