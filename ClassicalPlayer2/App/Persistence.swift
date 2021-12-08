//
//  Persistence.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/24/20.
// This matches
// https://www.donnywals.com/using-core-data-with-swiftui-2-0-and-xcode-12/
// We're punting setting up a save when app leaves foreground; maybe later.

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 1 ... 100 {
            let newItem = Album(context: viewContext)
            newItem.title = "\(i) title that goes on far too long"
            newItem.composer = "\(i) composer"
            newItem.artist = "Artist no. \(i)"
            newItem.trackCount = Int32(i)
            newItem.year = Int32(i + 2000)
            newItem.genre = "Genre no. \(i)"
            let newPiece = Piece(context: viewContext)
            newPiece.title = "Piece title no. \(i) With Really Long Title"
            newPiece.composer = "\(i) composer"
            newPiece.artist = "Artist no. \(i)"
            let newComposer = Composer(context: viewContext)
            newComposer.name = "\(i) composer"
            let newSong = Song(context: viewContext)
            newSong.composer = "\(i) composer"
            newSong.title = "Song no. \(i) With Extra-Long Title For Fun"
            newSong.artist = "Artist no. \(i)"
            newSong.duration = "\(i).00"
            newSong.album = newItem
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ClassicalPlayer2")
        if inMemory {
            //https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                 
                 -com.apple.CoreData.SQLDebug 1
                 /Users/fkuhl/Library/Containers/ClassicalPlayer2/Data/Library/Application Support/ClassicalPlayer2/ClassicalPlayer2.sqlite
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
