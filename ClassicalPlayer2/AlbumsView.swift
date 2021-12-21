//
//  AlbumsView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/15/21.
//

import SwiftUI
import CoreData

/**
 Albums for both size classes.
 See PiecesView for notes.
 */

struct AlbumsView: View, FilterUpdater {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass) var verticalSize
    private let sectionCount = 15 //a magic number chosen aesthetically.
    @State private var sort: AlbumSorts = .title
    @State private var albums: [Album] = []
    @State private var sectionMarkers: [(label: String, id: Album)] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if horizontalSize == .compact {
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
        .onChange(of: self.sort) { _ in  updateUI(filterText: "", in: viewContext) }
    }
    
    private var cList: some View {
        NavigationView {
            AlbumsListCView(albums: albums, sectionMarkers: sectionMarkers)
                .navigationTitle("Albums by \(sort.fieldName)")
                /**
                 If I just stack the TextField with the list, the TextField scrolls off the top of the screen when
                 the keyboard appears.
                 If I set the TextField as a navbar tool item, SwiftUI throws so many unsatisfied layout constrants
                 under the hood that it's unusable.
                 */
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) { searchField }
                    ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var rGrid: some View {
        Group {
            if horizontalSize == .regular && verticalSize == .compact {
                //big-phone landscape mode: need a NavView
                NavigationView {
                    AlbumsListRView(albums: albums, sectionMarkers: sectionMarkers)
                        .navigationTitle("Albums by \(sort.fieldName)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarLeading) { searchField }
                            ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                        })
                }.navigationViewStyle(StackNavigationViewStyle())
            } else {
                //We got here through RegularWidthView, which has a NavView
                AlbumsListRView(albums: albums, sectionMarkers: sectionMarkers)
                    .navigationTitle("Albums by \(sort.fieldName)")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) { searchField }
                        ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                    })
            }
        }
    }
    
    private var rGridGuts: some View {
        AlbumsListRView(albums: albums, sectionMarkers: sectionMarkers)
            .navigationTitle("Albums by \(sort.fieldName)")
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

    //FilterUpdater protocol
    func updateUI(filterText: String) {
        updateUI(filterText: filterText, in: viewContext)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(AlbumSorts.allCases, id: \.self) { sort in
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
    
    private func updateUI(filterText: String, in context: NSManagedObjectContext) {
        do {
            let request = albumsFetchRequest(filter: filterText, sort: sort, in: context)
            albums = try viewContext.fetch(request)
            /**
             We're sorting here rather than in the FetchRequest because the FetchRequest does not support
             our anarthrousCompare.
             */
            albums.sort {
                $0.sortField(sort).anarthrousCompare($1.sortField(sort)) == ComparisonResult.orderedAscending
            }
            if albums.count < sectionCount * 2 {
                sectionMarkers = []
                return
            }
            let sectionSize = albums.count / sectionCount
            sectionMarkers = []
            for i in 0 ..< sectionCount {
                let album = albums[i * sectionSize]
                let label = String((album.sortField(sort)).prefix(6))
                sectionMarkers.append((label: label, id: album))
            }
        } catch {
            errorMessage = "\(#file) \(#function) error fetching: \(error.localizedDescription)"
            NSLog(errorMessage)
            showingError = true
        }
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        AlbumsView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, context)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))

        AlbumsView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, context)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
    }
}
