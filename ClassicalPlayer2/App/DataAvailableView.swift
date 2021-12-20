//
//  DataAvailableView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/28/20.
//

import SwiftUI

struct DataAvailableView: View {
    @Environment(\.horizontalSizeClass) var size
    @ObservedObject var mediaLibrary = ClassicalMediaLibrary.shared
    @State var showingDataMissing = false
    @State var showingLibraryChanged = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if size == .compact {
                CompactWidthView()
            } else {
                RegularWidthView()
            }
            /**
             There used to be a ProgressView ZStack'd here, but the one in ContentView
             shows up nicely.
             */
            MusicPlayerView()
        }
        .alert(isPresented: $showingDataMissing) { dataMissingAlert() }
        .alert(isPresented: $showingLibraryChanged) { libraryChangedAlert() }
    }
    
    private func dataMissingAlert() -> Alert {
        let button = Alert.Button.default(Text("Got it.")) {
            mediaLibrary.dataMissing = false
        }
        return Alert(title: Text("Missing Media"),
                     message: Text("Some tracks do not have media. This probably can be fixed by synchronizing your device."),
                     dismissButton: button)
    }
    
    private func libraryChangedAlert() -> Alert {
        let loadButton = Alert.Button.default(Text("Load newest media")) {
            mediaLibrary.libraryChanged = false
            NSLog("starting replacement")
            self.mediaLibrary.replaceAppLibraryWithMedia()
        }
        let dontButton = Alert.Button.cancel(Text("Skip the load for now")) {
            mediaLibrary.libraryChanged = false
        }
        return Alert(title: Text("Music Library Chagned"),
                     message: Text("Load newest media?"),
                     primaryButton: loadButton,
                     secondaryButton: dontButton)
    }
}

struct DataAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        DataAvailableView()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 960, height: 540))
            .previewDevice("iPhone 8 Pro")
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}
