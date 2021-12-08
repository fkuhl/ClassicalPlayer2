//
//  PieceView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/5/21.
//

import SwiftUI
import MediaPlayer

struct PieceView: View {
    @Environment(\.horizontalSizeClass) var size
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var piece: Piece
    @State private var albumTapped = false
    @State private var showingTrackMissing = false

    var body: some View {
        if size == .regular {
            Spacer().frame(height: 50)
        }
        if let albumActual = piece.album {
            NavigationLink(destination: AlbumView(album: albumActual), isActive: $albumTapped) {
                header
            }
        } else {
            header
        }
        if movementsIsEmpty {
            Spacer()
        } else {
            MovementsView(movements: convertSet(movements: piece.movements!))
        }
    }
    
    private var header: some View {
        PieceHeaderView(title: piece.title ?? "[sine nomine]",
                        composer: piece.composer ?? "[anonymous]",
                        artist: piece.artist ?? "",
                        artwork: ClassicalMediaLibrary.artworkFor(album: piece.albumID),
                        albumTapped: $albumTapped)
            .onTapGesture() { headerTapped() }
            .alert(isPresented: $showingTrackMissing) { trackMissingAlert() }
    }
    
    private func headerTapped() {
        guard movementsIsEmpty else { return }
        musicPlayer.stopObserving()
        if let item = retrieveItem(from: piece) {
            musicPlayer.setPlayer(item: item, paused: false)
            musicPlayer.startObserving()
        } else {
            showingTrackMissing = true
        }
    }
    
    private func trackMissingAlert() -> Alert {
        let button = Alert.Button.default(Text("Got it.")) {  }
        return Alert(title: Text("Missing Media"),
                     message: Text("This track does not have media. This probably can be fixed by synchronizing your device."),
                     dismissButton: button)
    }

//    private func onMac() -> Bool {
//        #if targetEnvironment(macCatalyst)
//        return true
//        #else
//        return false
//        #endif
//    }
    
    private var movementsIsEmpty: Bool {
        if let movements = piece.movements {
            return movements.count == 0
        }
        return true
    }
}

/**
 The justification for keeping this as a defined view is that I can provide a preview for it.
 */
struct PieceHeaderView: View {
    @Environment(\.sizeCategory) var sizeCategory
    var title: String
    var composer: String
    var artist: String
    var artwork: UIImage
    @Binding var albumTapped: Bool
    
    var body: some View {
        VStack {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading) {
                    art
                    textStack
                }
            } else {
                HStack {
                    art
                    VStack {
                        Spacer()
                        textStack
                    }.frame(height: 200)
                    Spacer()
                }
            }
            Divider().background(Color(UIColor.systemGray))
        }
    }
    
    private var art: some View {
        VStack {
            Spacer()
            Image(uiImage: artwork)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .cornerRadius(5)
        }.frame(width: 200, height: 200)
    }
    
    private var textStack: some View {
        VStack(alignment: .leading) {
            Text(composer)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Text(artist)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.tail)
            Text("").font(.caption)
            Text("").font(.caption)
            Button(action: { albumTapped = true }) {
                Label("", systemImage: "rectangle.stack.fill").font(.caption)
            }
        }
    }
}

struct PieceHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PieceHeaderView(title: "Amazing Piece whose title goes on and on and on",
                        composer: "Schubert, Franz",
                        artist: "Momo Tsipler & His Wienerwald Companions",
                        artwork: ClassicalMediaLibrary.defaultImage,
                        albumTapped: .constant(false))
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}

struct MovementsView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @State private var firstSelectedIndex: Int? = nil
    var movements: [Movement]
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollValue in
            LazyVStack(alignment: .leading) {
                ForEach(0..<movements.count, id: \.self) { index in
                    MovementView(movements: movements,
                                 myIndex: index,
                                 firstSelectedIndex: $firstSelectedIndex)
                }
            }
            .onAppear() { scrollToPlaying() }
            .onChange(of: firstSelectedIndex) { _ in scrollOnSelection(value: scrollValue) }
            .onChange(of: musicPlayer.indexOfNowPlayingItem) { index in
                scrollOnChange(value: scrollValue, newValue: index)
            }
        }
        }
    }
    
    private func scrollToPlaying() {
        if let playingIndex = movements.firstIndex(where: {
            musicPlayer.nowPlayingItem?.persistentID == fromCoreData($0.trackID)
            }) {
            firstSelectedIndex = playingIndex
        }
    }
    
    private func scrollOnSelection(value scrollValue: ScrollViewProxy) {
        if let firstIndex = firstSelectedIndex {
            withAnimation {
                scrollValue.scrollTo(firstIndex, anchor: .top)
            }
        }
    }
    
    private func scrollOnChange(value scrollValue: ScrollViewProxy, newValue index: Int) {
        if let firstIndex = firstSelectedIndex {
            withAnimation {
                scrollValue.scrollTo(firstIndex + index, anchor: .top)
            }
        }
    }
}

/**
 This displays one Movement. It needs access to the list of Movements (actually, just a partial
 list) so it can fill the player queue.
 */
struct MovementView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer
    var movements: [Movement]
    var myIndex: Int
    @Binding var firstSelectedIndex: Int?

    var body: some View {
        VStack {
            HStack {
                PlayingIndicator(current: isCurrentTrack())
                Button(action: beginPlaying) {
                    Text(movements[myIndex].title ?? "[sine nomine]")
                        .font(.body)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                        .padding(.horizontal)
                }
                Spacer()
                Text(movements[myIndex].duration ?? "xx")
                    .font(.caption)
                    .padding(.horizontal)
            }
            Divider()
        }
    }
    
    private func isCurrentTrack() -> Bool {
        musicPlayer.nowPlayingItem?.persistentID == fromCoreData(movements[myIndex].trackID)
    }

    private func beginPlaying() {
        let partialList = movements[myIndex...]
        let playerItems = partialList.compactMap(retrieveItem)
        guard playerItems.count > 0 else {
            NSLog("MovementView.setQueuePlayer had no items")
            return
        }
        musicPlayer.stopObserving()
        musicPlayer.setPlayer(items: playerItems, tableIndex: myIndex, paused: false)
        firstSelectedIndex = myIndex
        musicPlayer.startObserving()
    }
}

private func convertSet(movements: NSOrderedSet) -> [Movement] {
    return movements.array.map { $0 as! Movement }
}

private func retrieveItem(from movement: Movement) -> MPMediaItem? {
    var item: MPMediaItem?
    let persistentID = fromCoreData(movement.trackID)
    let songQuery = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
    songQuery.addFilterPredicate(predicate)
    if let returned = songQuery.items {
        if returned.count > 0 { item = returned[0] }
    }
    return item
}

private func retrieveItem(from: Piece?) -> MPMediaItem? {
    var item: MPMediaItem?
    if let piece = from {
        let persistentID = fromCoreData(piece.trackID)
        let songQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
        songQuery.addFilterPredicate(predicate)
        if let returned = songQuery.items {
            if returned.count > 0 { item = returned[0] }
        }
    }
    return item
}
