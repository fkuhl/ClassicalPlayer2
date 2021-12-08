//
//  ClassicalPlayer2App.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/24/20.
//

import SwiftUI

@main
struct ClassicalPlayer2App: App {
    let persistenceController = PersistenceController.shared
    let musicPlayer = MusicPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(musicPlayer)
        }
    }
}
