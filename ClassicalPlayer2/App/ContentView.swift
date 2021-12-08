//
//  ContentView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/24/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @ObservedObject var mediaLibrary = ClassicalMediaLibrary.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                lama.frame(maxWidth: geometry.size.width, maxHeight: .infinity)
                switch mediaLibrary.status {
                case .initial:
                    ZStack {
                        EmptyView()
                        //lama.frame(maxWidth: geometry.size.width, maxHeight: .infinity)
                        //Color.gray.opacity(0.5).ignoresSafeArea()
                    }
                case .authorized:
                    EmptyView()
                    //lama.frame(maxWidth: geometry.size.width, maxHeight: .infinity)
                case .restricted(message: let message):
                    VStack {
                        Text("Access to your music library is restricted:").font(.headline)
                        Text(message).font(.subheadline)
                    }
                case .denied(message: let message):
                    VStack {
                        Text("Access to your music library is denied:").font(.headline)
                        Text(message).font(.subheadline)
                    }
                case .dataAvailable:
                    DataAvailableView(showingDataMissing: mediaLibrary.dataMissing,
                                      showingLibraryChanged: mediaLibrary.libraryChanged)
                case .coreDataError(message: let message):
                    VStack {
                        Text("Something is wrong with the app's storage:").font(.headline)
                        Text(message).font(.subheadline)
                        Text("Alas, there is little we can do.").font(.subheadline)
                    }
                }
                if mediaLibrary.showingProgress {
                    LoadingView()
                        .frame(maxWidth: geometry.size.width * 0.67, maxHeight: .infinity)
                }
            }
        }
        .onAppear() {
            mediaLibrary.initializeAudio()
            mediaLibrary.checkMediaLibraryAccess()
            musicPlayer.initializeFromPlayer()
        }
    }
    
    private var lama: some View {
        Image("Lama_asabthani")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                        .previewDisplayName("iPhone 12")
        
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro 9.7"))
                        .previewDisplayName("iPad")
            .previewLayout(.fixed(width: 1024, height: 768))
    }
}
