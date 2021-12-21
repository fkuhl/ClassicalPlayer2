//
//  InfoView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/2/21.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.verticalSizeClass) var verticallSize
    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject private var musicPlayer: MusicPlayer
    @ObservedObject var mediaLibrary = ClassicalMediaLibrary.shared
    @ScaledMetric(relativeTo: .headline) var dateTitleWidth: CGFloat = 150
    @ScaledMetric(relativeTo: .body) var datumTitleWidth: CGFloat = 150
    @ScaledMetric(relativeTo: .body) var datumStringWidth: CGFloat = 70

    var body: some View {
        if verticallSize == .regular {
            VStack {
                header
                libraryInfo
                Button(action: reloadLibrary) {
                    Text("Reload Music Library").font(.headline)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("")
            //Makes the space for the invisible title smaller!
            .navigationBarTitleDisplayMode(.inline)
        } else {
            HStack {
                VStack {
                    header
                    libraryInfo
                        .padding()
                    Spacer()
                }
                Button(action: reloadLibrary) {
                    Text("Reload Library").font(.headline)
                }.padding()
                Spacer()
            }
            .navigationTitle("")
            //Makes the space for the invisible title smaller!
            .navigationBarTitleDisplayMode(.inline)
        }
        /**
         Here you might expect a ProgressView that would appear when the library is reloaded.
         There is already a ProgressView in the view hierarchy; see DataAvailableView.
         And that one appears!
         */
    }
    
    private func reloadLibrary() {
        mediaLibrary.replaceAppLibraryWithMedia()
    }
    
    private var header: some View {
        VStack {
            if sizeCategory.isAccessibilityCategory {
                HStack {
                    VStack(alignment: .leading) {
                        icon
                        textStack
                    }
                    .padding()
                    Spacer()
                }
            } else {
                HStack {
                    icon
                    textStack
                    Spacer()
                }
            }
            Divider().background(Color(UIColor.systemGray))
        }
    }
    
    private var icon: some View {
        Image("info-icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150)
            .cornerRadius(7)
            .padding(.leading)
    }
    
    private var textStack: some View {
        VStack(alignment: .leading) {
            Text("ClassicalPlayer2")
                .font(.headline)
                .padding(.bottom)
            Text("Copyright © 2021")
                .font(.caption)
            Text("TyndaleSoft LLC")
                .font(.caption)
            Text("All Rights Reserved.")
                .font(.caption)
            Text(buildAndVersion)
                .font(.caption)
                .padding(.top)
        }
    }
    
    private let buildAndVersion =
        "v \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""), " +
        "build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "")"
    
    private var libraryInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Library date:")
                        .font(.headline)
                        .frame(width: dateTitleWidth, alignment: .topTrailing)
                    Text(libraryDateString())
                        .font(.headline)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        .frame(width: 200, alignment: .topTrailing)
                }
                datumView(title: "Albums:",
                          number: ClassicalMediaLibrary.shared.mediaLibraryInfo.albums)
                datumView(title: "Tracks:",
                          number: ClassicalMediaLibrary.shared.mediaLibraryInfo.songs)
                datumView(title: "Pieces:",
                          number: ClassicalMediaLibrary.shared.mediaLibraryInfo.pieces)
                datumView(title: "Movements:",
                          number: ClassicalMediaLibrary.shared.mediaLibraryInfo.movements)
                datumView(title: "Playlists:",
                          number: ClassicalMediaLibrary.shared.mediaLibraryInfo.playlists)
            }
            .padding()
            Spacer()
        }
    }
    
    private func libraryDateString() -> String {
        let mediaLibraryInfo = ClassicalMediaLibrary.shared.mediaLibraryInfo
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        let dateString: String
        if let mediaDate = mediaLibraryInfo.date  {
            dateString = dateFormatter.string(from: mediaDate)
        } else {
            dateString = "[n.d.]"
        }
        return dateString
    }
    
    private func datumView(title: String, number: Int32) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .frame(width: datumTitleWidth, alignment: .topTrailing)
            Text("\(number)")
                .font(.body)
                .frame(width: datumStringWidth, alignment: .topTrailing)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        InfoView()
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 896, height: 414))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .compact)
            .environmentObject(MusicPlayer())
        
        InfoView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
            .environmentObject(MusicPlayer())
    }
}
