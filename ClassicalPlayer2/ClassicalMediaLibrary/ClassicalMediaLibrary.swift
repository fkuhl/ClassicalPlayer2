//
//  ClassicalMediaLibrary.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/26/20.
//

import Foundation
import CoreData
import MediaPlayer
import AVKit

public class ClassicalMediaLibrary: ObservableObject {
    
    public enum Status {
        case initial
        case authorized
        case restricted(message: String)
        case denied(message: String)
        case dataAvailable
        case coreDataError(message: String)
    }
    
    private static let showParses = false
    private static let showPieces = false
    //For app screenshots, set this to true to load only "fake" genre
    static let loadOnlyFake = false
    static let fakeGenre = "fake"

    
    public static let shared = ClassicalMediaLibrary()
    @Published var composersInLibrary = Set<String>()
    @Published var composersAsArray = [String]()
    @Published var status: Status = .initial
    @Published var dataMissing: Bool = false
    @Published var libraryChanged: Bool = false
    @Published var showingProgress: Bool = false
    @Published var composersProgress: CGFloat = 0.0
    @Published var albumsProgress: CGFloat = 0.0
    @Published var playlistsProgress: CGFloat = 0.0

    private var libraryAccessChecked = false
    private var viewContext = PersistenceController.shared.container.viewContext
    
    private var libraryDate: Date?
    private var libraryAlbumCount: Int32 = 0
    private var librarySongCount: Int32 = 0
    private var libraryPieceCount: Int32 = 0
    private var libraryMovementCount: Int32 = 0
    private var libraryPlaylistCount: Int32 = 0
    
    public var mediaLibraryInfo: (date: Date?,
                                  albums: Int32,
                                  songs: Int32,
                                  pieces: Int32,
                                  movements: Int32,
                                  playlists: Int32) {
        get {
            return (date: libraryDate,
                    albums: libraryAlbumCount,
                    songs: librarySongCount,
                    pieces: libraryPieceCount,
                    movements: libraryMovementCount,
                    playlists: libraryPlaylistCount)
        }
    }

    lazy var audioBarSetLight: [UIImage] = { return makeAudioBars(namePrefix: "bars") }()
    lazy var audioBarSetDark: [UIImage] = { return makeAudioBars(namePrefix: "bars-light") }()
    lazy var audioPausedLight: UIImage? = { return UIImage(named:"bars-paused") }()
    lazy var audioPausedDark: UIImage? = { return UIImage(named:"bars-light-paused") }()
    lazy var audioNotCurrent: UIImage? = { return UIImage(named:"bars-light-current") }()
    
    private func makeAudioBars(namePrefix: String) -> [UIImage] {
        var bars = [UIImage]()
        for imageFrame in 1...10 {
            let image = UIImage(named:"\(namePrefix)-\(imageFrame)")
            if let frame = image {
                bars.append(frame)
            }
        }
        return bars
    }
    
    func checkMediaLibraryAccess() {
        if libraryAccessChecked { return }
        //Check authorization to access media library
        MPMediaLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                break //not clear how you'd ever get here, as the request will determine authorization
            case .authorized:
                //Avoid the assumption that we know what thread requestAuthorization returns on
                DispatchQueue.main.async {
                    NSLog("access authorized")
                    self.status = .authorized
                    self.checkLibraryChanged()
                }
            case .restricted:
                NSLog("restricted")
                self.status = .restricted(message: "Media library access restricted by corporate or parental controls")
            case .denied:
                NSLog("denied")
                self.status = .denied(message: "Please give ClassicalPlayer access to your Media Library and restart it.")
            @unknown default:
                fatalError("\(#file) - \(#function) unknown library access enum \(authorizationStatus)")
            }
            self.libraryAccessChecked = true
        }
    }
    
    // MARK: - Media library info

    func checkLibraryChanged() {
        do {
            let libraryInfos = try getMediaLibraryInfo(from: viewContext)
            if libraryInfos.count < 1 {
                NSLog("No app library found: load media lib to app")
                try loadMediaLibraryInitially()
                return
            }
            let mediaLibraryInfo = libraryInfos[0]
            if let storedLastModDate = mediaLibraryInfo.lastModifiedDate {
                if MPMediaLibrary.default().lastModifiedDate <= storedLastModDate {
                    //use current data
                    NSLog("media lib stored \(MPMediaLibrary.default().lastModifiedDate), app lib stored \(storedLastModDate): use current app lib")
                    try logCurrentNumberOfAlbums(into: viewContext)
                    updateAppDelegateLibraryInfo(from: mediaLibraryInfo)
                    status = .dataAvailable
                    return
                }  else {
                    NSLog("media lib stored \(MPMediaLibrary.default().lastModifiedDate), app lib data \(storedLastModDate): media lib changed, replace app lib")
                    try logCurrentNumberOfAlbums(into: viewContext)
                    updateAppDelegateLibraryInfo(from: mediaLibraryInfo)
                    status = .dataAvailable
                    libraryChanged = true
                    return
                }
            } else {
                status = .coreDataError(message: "Last modification date not set in media library info")
                NSLog("Last modification date not set in media library info")
            }
        } catch {
            status = .coreDataError(message: error.localizedDescription)
        }
    }
    
    private func updateAppDelegateLibraryInfo(from info: MediaLibraryInfo) {
        //NSLog("updateAppDelegateLibraryInfo to date \(String(describing: info.lastModifiedDate)), albums: \(info.albumCount)")
        libraryDate = info.lastModifiedDate
        libraryAlbumCount = info.albumCount
        librarySongCount = info.songCount
        libraryPieceCount = info.pieceCount
        libraryMovementCount = info.movementCount
        libraryPlaylistCount = info.playlistCount
    }
    
    private func logCurrentNumberOfAlbums(into context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<Album>()
        request.entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
        request.resultType = .managedObjectResultType
        let albums = try context.fetch(request)
        NSLog("\(albums.count) albums")
    }
    
    func retrieveMediaLibraryInfo(from context: NSManagedObjectContext) throws {
        var mediaInfoObject: MediaLibraryInfo
        let mediaLibraryInfosInStore = try getMediaLibraryInfo(from: context)
        if mediaLibraryInfosInStore.count >= 1 {
            mediaInfoObject = mediaLibraryInfosInStore[0]
            libraryDate = mediaInfoObject.lastModifiedDate
            libraryAlbumCount = mediaInfoObject.albumCount
            librarySongCount = mediaInfoObject.songCount
            libraryPieceCount = mediaInfoObject.pieceCount
            libraryMovementCount = mediaInfoObject.movementCount
            libraryPlaylistCount = mediaInfoObject.playlistCount
        }
    }
    
    private func storeMediaLibraryInfo(into context: NSManagedObjectContext) throws {
        var mediaInfoObject: MediaLibraryInfo
        let mediaLibraryInfosInStore = try getMediaLibraryInfo(from: context)
        if mediaLibraryInfosInStore.count >= 1 {
            mediaInfoObject = mediaLibraryInfosInStore[0]
        } else {
            mediaInfoObject = NSEntityDescription.insertNewObject(
                forEntityName: "MediaLibraryInfo",
                into: context) as! MediaLibraryInfo
        }
        mediaInfoObject.lastModifiedDate = MPMediaLibrary.default().lastModifiedDate
        mediaInfoObject.albumCount = libraryAlbumCount
        mediaInfoObject.movementCount = libraryMovementCount
        mediaInfoObject.pieceCount = libraryPieceCount
        mediaInfoObject.songCount = librarySongCount
        mediaInfoObject.playlistCount = libraryPlaylistCount
    }


    private func getMediaLibraryInfo(from context: NSManagedObjectContext) throws -> [MediaLibraryInfo] {
        let request = NSFetchRequest<MediaLibraryInfo>()
        request.entity = NSEntityDescription.entity(
            forEntityName: "MediaLibraryInfo",
            in: context)
        request.resultType = .managedObjectResultType
        return try context.fetch(request)
    }
    
    // MARK: - Load app from Media library

    /**
     Load app from Media Library without clearing old data.
     Used by AppDelegate when there was no app library.
     
     - Precondition: App has authorization to access library
    */
    private func loadMediaLibraryInitially() throws {
        PersistenceController.shared.container.performBackgroundTask() { context in
            do {
                let loadReturn = try self.loadAppFromMediaLibrary(context: context)
                try context.save()
                switch (loadReturn) {
                case .normal:
                    DispatchQueue.main.async {
                        self.status = .dataAvailable
                    }
                case .missingData:
                    DispatchQueue.main.async {
                        self.status = .dataAvailable
                        self.dataMissing = true
                    }
                }
            } catch {
                let error = error as NSError
                let message = "save error in replaceAppLibraryWithMedia: \(error), \(error.userInfo)"
                NSLog(message)
                DispatchQueue.main.async {
                    self.status = .coreDataError(message: message)
                }
            }
        }
    }
    
    private enum LoadReturn {
        case normal
        case missingData
    }

    /**
     Load the app's lib (CoreData) from media lib.
     Before this calls any parsing functions it strips any MediaItems whose assetURL is nil.
     This may affect parsing, but all parsing functions can assume no nil URLs.
     
     - Parameters:
     - context: Coredata context
     
     - Returns:
     whether any media (asset URLs) were missing.
     */
    private func loadAppFromMediaLibrary(context: NSManagedObjectContext) throws -> LoadReturn {
        var allMediaDataPresent = true
        NSLog("findComposers begin")
        DispatchQueue.main.async {
            self.composersProgress =  0.0
            self.albumsProgress = 0.0
            self.playlistsProgress = 0.0
            ClassicalMediaLibrary.shared.showingProgress = true
        }
        findComposers()
        NSLog("findComposers \(composersCount()) composers from albums & tracks")
        libraryDate = MPMediaLibrary.default().lastModifiedDate
        libraryAlbumCount = 0
        libraryPieceCount = 0
        librarySongCount = 0
        libraryMovementCount = 0
        libraryPlaylistCount = 0
        let progressIncrement = Int32(max(1, getAlbumCount() / 50)) //update progress bar 20 times
        let mediaAlbums = MPMediaQuery.albums()
        if let collections = mediaAlbums.collections {
            for mediaAlbum in collections {
                var mediaAlbumItems = mediaAlbum.items
                mediaAlbumItems.removeAll(where: { !$0.isPlayable() })
                if someItemsMissingMedia(from: mediaAlbumItems) { allMediaDataPresent = false }
                self.libraryAlbumCount += 1
                if self.libraryAlbumCount % progressIncrement == 0 {
                    DispatchQueue.main.async {
                        self.albumsProgress = CGFloat(self.libraryAlbumCount) / CGFloat(getAlbumCount())
                    }
                }
                if ClassicalMediaLibrary.showPieces /*&& self.isGenreToParse(mediaAlbumItems[0].genre )*/ {
                    print("Album: \(mediaAlbumItems[0].composer ?? "<anon>"): "
                        + "\(mediaAlbumItems[0].albumTrackCount) "
                        + "\(mediaAlbumItems[0].albumTitle ?? "<no title>")"
                        + " | \(mediaAlbumItems[0].albumArtist ?? "<no artist>")"
                        + " | \((mediaAlbumItems[0].value(forProperty: "year") as? Int) ?? -1) ")
                }
                if mediaAlbumItems.isEmpty {
                    NSLog("empty album, title: '\(mediaAlbum.representativeItem?.albumTitle ?? "")'")
                    continue
                }
                if Self.loadOnlyFake && mediaAlbumItems[0].genre != Self.fakeGenre { continue }
                let appAlbum = makeAndFillAlbum(from: mediaAlbumItems,
                                                     into: context)
                //For now, just parse everything irrespective of genre. One less thing to explain.
                loadParsedPieces(for: appAlbum, from: mediaAlbumItems, into: context)
            }
            loadPlaylists(into: context)
        }
        try context.save()
        //loadAllSongs(into: context)
        try storeComposersFromPieces(into: context)
        try context.save()
        DispatchQueue.main.async {
            self.showingProgress = false
        }
        NSLog("found \(composersCount()) composers, \(libraryAlbumCount) albums, \(libraryPieceCount) pieces, \(libraryMovementCount) movements, \(librarySongCount) songs, \(libraryPlaylistCount) playlists")
        try storeMediaLibraryInfo(into: context)
        return allMediaDataPresent ? .normal : .missingData
    }
    
    private func someItemsMissingMedia(from items: [MPMediaItem]) -> Bool {
        return items.reduce(false, { wereMissing, item in
            wereMissing || (item.playabilityCategory() == .missingMedia)
        })
    }
    
    private func makeAndFillAlbum(from mediaAlbumItems: [MPMediaItem],
                                  into context: NSManagedObjectContext) -> Album {
        let album = NSEntityDescription.insertNewObject(forEntityName: "Album", into: context) as! Album
        //Someday we may purpose "artist" as a composite field containing ensemble, director, soloists
        album.artist = mediaAlbumItems[0].albumArtist
        album.title = mediaAlbumItems[0].albumTitle
        album.composer = (mediaAlbumItems[0].composer ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        album.genre = mediaAlbumItems[0].genre
        album.trackCount = Int32(mediaAlbumItems[0].albumTrackCount)
        album.albumID = toCoreData(mediaAlbumItems[0].albumPersistentID)
        album.year = mediaAlbumItems[0].value(forProperty: "year") as! Int32  //slightly undocumented!
        load(songs: mediaAlbumItems, album: album, into: context)
        return album
    }
    
    private func load(songs: [MPMediaItem],
                      album: Album,
                      into context: NSManagedObjectContext) {
        for item in songs {
            if !item.isPlayable() { continue }
            if Self.loadOnlyFake && item.genre != Self.fakeGenre { continue }
            librarySongCount += 1
            let song = NSEntityDescription.insertNewObject(forEntityName: "Song",
                                                           into: context) as! Song
            song.persistentID = toCoreData(item.persistentID)
            song.albumID = toCoreData(item.albumPersistentID)
            song.artist = item.artist
            song.duration = ClassicalMediaLibrary.durationAsString(item.playbackDuration)
            song.title = item.title
            song.trackURL = item.assetURL
            song.composer = item.composer
            song.album = album
        }
    }
    
    private func loadPlaylists(into context: NSManagedObjectContext) {
        NSLog("loadPlaylists begin")
        let myPlaylistQuery = MPMediaQuery.playlists()
        if let playlists = myPlaylistQuery.collections {
            let playlistCount = playlists.count
            let progressIncrement = Int32(max(1, playlistCount / 20))
            for item in playlists {
                libraryPlaylistCount += 1
                let list = item as! MPMediaPlaylist
                let playlist = NSEntityDescription.insertNewObject(forEntityName: "Playlist",
                                                               into: context) as! Playlist
                playlist.persistentID = toCoreData(list.persistentID)
                playlist.name = list.name
                playlist.descriptionText = list.descriptionText
                playlist.authorDisplayName = list.authorDisplayName
                if let representative = list.representativeItem {
                    playlist.albumID = toCoreData(representative.albumPersistentID)
                }
                for track in list.items {
                    if let song = songFor(track: track, in: context) {
                        playlist.addToSongs(song)
                        song.addToPlaylists(playlist)
                    }
                }
                if libraryPlaylistCount % progressIncrement == 0 {
                    DispatchQueue.main.async {
                        self.playlistsProgress = CGFloat(self.libraryPlaylistCount) / CGFloat(playlistCount)
                    }
                }
            }
        }
        NSLog("loadPlaylists end")
    }
    
    /**
     Load all songs from the library.
     This collects all songs, whether they are part of an album or not.
     */
//    private func loadAllSongs(into context: NSManagedObjectContext) {
//        if let items = MPMediaQuery.songs().items {
//            librarySongCount = Int32(0)
//            for item in items {
//                if !item.isPlayable() { continue }
//                if Self.loadOnlyFake && item.genre != Self.fakeGenre { continue }
//                librarySongCount += 1
//                let song = NSEntityDescription.insertNewObject(forEntityName: "Song",
//                                                               into: context) as! Song
//                song.persistentID = toCoreData(item.persistentID)
//                song.albumID = toCoreData(item.albumPersistentID)
//                song.artist = item.artist
//                song.duration = ClassicalMediaLibrary.durationAsString(item.playbackDuration)
//                song.title = item.title
//                song.trackURL = item.assetURL
//                song.composer = item.composer
//                if let album = albumsFor(track: item, in: context).first {
//                    song.album = album
//                }
//            }
//            NSLog("found \(librarySongCount) songs")
//        }
//    }
//
    private func loadParsedPieces(for album: Album,
                                  from collection: [MPMediaItem],
                                  into context: NSManagedObjectContext) {
        var piece: Piece?
        if collection.count < 1 { return }
        let trackTitles = collection.map { return $0.title ?? "" }
        parsePieces(from: trackTitles,
                    recordPiece: { (collectionIndex: Int, pieceTitle: String, parseResult: ParseResult) in
                        piece = storePiece(from: collection[collectionIndex], entitled: pieceTitle, to: album, into: context)
                        if ClassicalMediaLibrary.showParses {
                            print("composer: '\(collection[collectionIndex].composer ?? "")' raw: '\(trackTitles[collectionIndex])'")
                            print("   piece: '\(parseResult.firstMatch)' movement: '\(parseResult.secondMatch)' (\(parseResult.parse.name))")
                        }
        },
                    recordMovement: { (collectionIndex: Int, movementTitle: String, parseResult: ParseResult) in
                        storeMovement(from: collection[collectionIndex],
                                      named: movementTitle,
                                      for: piece!,
                                      into: context)
                        if ClassicalMediaLibrary.showParses {
                            print("      movt raw: '\(trackTitles[collectionIndex])' second title: '\(movementTitle)' (\(parseResult.parse.name))")
                        }
        })
    }

    private func storeMovement(from item: MPMediaItem,
                               named: String,
                               for piece: Piece,
                               into context: NSManagedObjectContext) {
        let mov = NSEntityDescription.insertNewObject(forEntityName: "Movement",
                                                      into: context) as! Movement
        mov.title = named
        mov.trackID = toCoreData( item.persistentID)
        mov.trackURL = item.assetURL
        mov.duration = ClassicalMediaLibrary.durationAsString(item.playbackDuration)
        libraryMovementCount += 1
        piece.addToMovements(mov)
        if ClassicalMediaLibrary.showPieces { print("    '\(mov.title ?? "")'") }
    }

    //assumption: check has been performed by caller that assetURL is not nil
    private func storePiece(from mediaItem: MPMediaItem,
                            entitled title: String,
                            to album: Album,
                            into context: NSManagedObjectContext) -> Piece {
        if ClassicalMediaLibrary.showPieces && mediaItem.genre == "Classical" {
            let genreMark = (mediaItem.genre == "Classical") ? "!" : ""
            print("  \(genreMark)|\(mediaItem.composer ?? "<anon>")| \(title)")
        }
        let piece = NSEntityDescription.insertNewObject(forEntityName: "Piece", into: context) as! Piece
        piece.albumID = toCoreData(mediaItem.albumPersistentID)
        libraryPieceCount += 1
        piece.composer = (mediaItem.composer ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        piece.artist = mediaItem.artist ?? ""
        piece.artistID = toCoreData(mediaItem.artistPersistentID)
        piece.genre = mediaItem.genre ?? ""
        piece.title = title
        piece.album = album
        piece.trackID = toCoreData(mediaItem.persistentID)
        piece.trackURL = mediaItem.assetURL
        album.addToPieces(piece)
        return piece
    }
    
    private func storeComposersFromPieces(into context: NSManagedObjectContext) throws {
        NSLog("storeComposers begin")
        let request = NSFetchRequest<NSDictionary>()
        request.entity = NSEntityDescription.entity(forEntityName: "Piece", in: context)
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = [ "composer" ]
        request.predicate = NSPredicate(format: "composer <> %@", "") //No blank composers!
        let composerObjects = try context.fetch(request)
        for composerObject in composerObjects {
            if let name = composerObject["composer"] as? String {
                let composer = NSEntityDescription.insertNewObject(
                    forEntityName: "Composer",
                    into: context) as! Composer
                composer.name = name
            }
        }
        NSLog("storeComposers: \(composerObjects.count) composers from pieces")
    }

    // MARK: - Replace app library with Media library

    /**
     Clear out old app library, and replace with media library contents.
     
     Note that the load is done on a background thread!
     Because we can't update the progress bar if the CoreData stuff is hogging the main thread.
     loadAppFromMediaLibrary makes progress calls back to a delegate,
     which must handle its UI updates on main thread.
     
     - Precondition: App has authorization to access library
     */
    func replaceAppLibraryWithMedia() {
        PersistenceController.shared.container.performBackgroundTask() { context in
            do {
                try self.clearOldData(from: context)
                let loadReturn = try self.loadAppFromMediaLibrary(context: context)
                try context.save()
                switch (loadReturn) {
                case .normal:
                    DispatchQueue.main.async {
                        self.status = .dataAvailable
                    }
                case .missingData:
                    DispatchQueue.main.async {
                        self.status = .dataAvailable
                        self.dataMissing = true
                    }
                }
            } catch {
                let error = error as NSError
                let message = "save error in replaceAppLibraryWithMedia: \(error), \(error.userInfo)"
                NSLog(message)
                DispatchQueue.main.async {
                    self.status = .coreDataError(message: message)
                }
            }
        }
    }
    
    private func clearOldData(from context: NSManagedObjectContext) throws {
        try clearEntities(ofType: "Movement", from: context)
        try clearEntities(ofType: "Piece", from: context)
        try clearEntities(ofType: "Album", from: context)
        try clearEntities(ofType: "Song", from: context)
        try clearEntities(ofType: "Composer", from: context)
        try clearEntities(ofType: "Playlist", from: context)
        try context.save()
    }
    
    private func clearEntities(ofType type: String,
                               from context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: type, in:context)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        request.predicate = NSPredicate(format: "title LIKE %@", ".*")
        deleteRequest.resultType = .resultTypeCount
        let deleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
        NSLog("deleted \(deleteResult?.result ?? "<nil>") \(type)")
    }

    // MARK: - Artwork, etc.

    /**
     Get artwork for an album.
     
     - Parameters:
     - album: persistentID of album
     
     - Returns:
     What's returned is (see docs) "smallest image at least as large as specified"--
     which turns out to be 600 x 600, with no discernible difference for the albums
     with iTunes LPs.
     */
    public static func artworkFor(album: MPMediaEntityPersistentID) -> UIImage? {
        //In build 21, artwork is always enabled!
        //        if !UserDefaults.standard.bool(forKey: displayArtworkKey) {
        //            return AppDelegate.defaultImage
        //        }
        let query = MPMediaQuery.albums()
        let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumPersistentID)
        query.filterPredicates = Set([ predicate ])
        if let results = query.collections {
            if results.count >= 1 {
                let result = results[0].items[0]
                let propertyVal = result.value(forProperty: MPMediaItemPropertyArtwork)
                let artwork = propertyVal as? MPMediaItemArtwork
                var returnedImage: UIImage? = nil
                if let bounds = artwork?.bounds {
                    returnedImage = artwork?.image(at: CGSize(width: bounds.width, height: bounds.height))
                }
                return returnedImage
            }
        }
        return nil
    }
    
    static var defaultImage: UIImage = UIImage(named: "default-album", in: nil, compatibleWith: nil)!
    
    static func artworkFor(album: Int64?) -> UIImage {
        if let realAlbum = album {
            return Self.artworkFor(album: fromCoreData(realAlbum))
        }
        return Self.defaultImage
    }
    
    static func artworkFor(album: MPMediaEntityPersistentID) -> UIImage {
        if let returnedImage = ClassicalMediaLibrary.artworkFor(album: album) {
            return returnedImage
        }
        return Self.defaultImage
    }
    
    /**
     Represesentation of a the duration of a song, suitable for display.
     */
    public static func durationAsString(_ duration: TimeInterval) -> String {
        let min = Int(duration/60.0)
        let sec = Int(CGFloat(duration).truncatingRemainder(dividingBy: 60.0))
        return String(format: "%d:%02d", min, sec)
    }
    
    // MARK: - Audio

    public func initializeAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //In addition to setting this audio mode, info.plist contains a "Required background modes" key,
            //with an "audio" ("app plays audio ... AirPlay") entry.
            try audioSession.setCategory(AVAudioSession.Category.playback,
                                         mode: AVAudioSession.Mode.default,
                                         policy: AVAudioSession.RouteSharingPolicy.longFormAudio) //enable AirPlay
        } catch {
            let error = error as NSError
            NotificationCenter.default.post(Notification(name: .initializingError,
                                                         object: self,
                                                         userInfo: error.userInfo))
            NSLog("error setting category to AVAudioSessionCategoryPlayback: \(error), \(error.userInfo)")
        }
    }

}

// MARK: - Core Data helpers

public func toCoreData(_ from: MPMediaEntityPersistentID) -> Int64 {
    Int64(bitPattern: from)
}

public func fromCoreData(_ from: Int64) -> MPMediaEntityPersistentID {
    UInt64(bitPattern: from)
}

func albumsFor(track: MPMediaItem,
               in context: NSManagedObjectContext) -> [Album] {
    do {
        let request = NSFetchRequest<Album>()
        request.entity = NSEntityDescription.entity(forEntityName: "Album",
                                                    in: context)
        let format = String(format: "albumID == %d", track.albumPersistentID)
        let predicate = NSPredicate(format: /*"albumID == %d"*/ format, toCoreData(track.albumPersistentID))
        request.predicate = predicate
        let returned = try context.fetch(request)
        NSLog("albumsFor \(format) returned \(returned.count)")
        return returned
    } catch {
        NSLog("\(#file) \(#function) error fetching: \(error.localizedDescription)")
        return []
    }
}
