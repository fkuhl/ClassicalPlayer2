//
//  RoundedOutlineButton.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/29/20.
//

import SwiftUI

//https://www.bigmountainstudio.com/members/posts/11623-5-swiftui-button-designs-every-swiftui-developer-should-know

struct RoundedOutlineButton: View {
    var text = "Some Text"
    var action: () -> Void
    
    var body: some View {
        Button(action:action) {
            Text(text).font(.body)
                .padding()
        }
        .background(Capsule().stroke(Color.accentColor, lineWidth: 2))
    }
}

struct RoundedOutlineButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedOutlineButton(text: "Preview Text", action: { })
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
}
