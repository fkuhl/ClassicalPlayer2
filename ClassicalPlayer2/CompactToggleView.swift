//
//  CompactToggleView.swift
//  PMClient
//
//  Created by Frederick Kuhl on 6/18/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI

struct CompactToggleView: View {
    @Binding var isOn: Bool
    var label: String
    
    var body: some View {
        HStack {
            Text(label).font(.body)
            //include label for accessibility
            Toggle(label, isOn: $isOn)
                .toggleStyle(CheckboxToggleStyle())
        }.labelsHidden()
    }
}

struct CompactToggleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CompactToggleView(isOn: .constant(true), label: "Show on")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("On")
            
            CompactToggleView(isOn: .constant(false), label: "Show off")
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Off")
        }
    }
}
