//
//  MusicPlayerView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 2/18/21.
//

import SwiftUI

struct MusicPlayerView: View {
    @EnvironmentObject var musicPlayer: MusicPlayer
    @Environment(\.horizontalSizeClass) var size
    
    var body: some View {
        if musicPlayer.isActive || runningInPreview() {
            if size == .compact {
                MusicPlayerCView()
            } else {
                MusicPlayerRView()
            }
        }
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        MusicPlayerView()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 896, height: 414))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
    }
}
