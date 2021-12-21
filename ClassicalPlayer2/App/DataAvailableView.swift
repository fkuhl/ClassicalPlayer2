//
//  DataAvailableView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/28/20.
//

import SwiftUI

struct DataAvailableView: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass) var verticalSize
    @ObservedObject var mediaLibrary = ClassicalMediaLibrary.shared
    @State var showingDataMissing = false
    @State var showingLibraryChanged = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if horizontalSize == .regular && verticalSize == .regular {
                RegularWidthView()
            } else {
                CompactWidthView()
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
        //logical size of XS Max
            .previewLayout(.fixed(width: 896, height: 414))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .compact)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
        
        DataAvailableView()
            .preferredColorScheme(.dark)
        //logical size of XS Ma x
            .previewLayout(.fixed(width: 414, height: 896))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
        
        DataAvailableView()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 900, height: 500))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .regular)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}
