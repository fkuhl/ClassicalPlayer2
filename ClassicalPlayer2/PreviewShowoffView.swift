//
//  PreviewShowoffView.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/21/20.
//

/**
 See PreviewProviderModifier.swift
 */
#if DEBUG
import SwiftUI

public struct PreviewShowoffView: View {
    public var body: some View {
        Label("Hello, World!", systemImage: "hand.wave.fill")
    }
}

public struct PreviewShowoffView_Previews: PreviewProvider {
    public static var previews: some View {
        PreviewShowoffView()
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}

#endif
