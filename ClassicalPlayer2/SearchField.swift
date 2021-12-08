//
//  SearchField.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 3/30/21.
//

import SwiftUI

struct SearchField: View {
    @State private var filterText = ""
    var uiUpdater: FilterUpdater
    var sortFieldName: String
    @State private var showingXCircle = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").font(.caption)
            TextField("Filter by \(sortFieldName)",
                      text: $filterText,
                      onCommit: {
                        uiUpdater.updateUI(filterText: filterText)
                        showingXCircle = filterText.count > 0
                      })
                .font(.body)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            if showingXCircle {
                Button(action: clearFilter) {
                    Label("", systemImage: "xmark.circle").font(.caption)
                }
            }
        }
    }
    
    private func clearFilter() {
        filterText = ""
        showingXCircle = false
        uiUpdater.updateUI(filterText: filterText)
    }
}

struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        
        SearchField(uiUpdater: PreviewUpdater(),
                    sortFieldName: "some sort")
            .padding()
            .background(Color(.systemBackground))
            .makeForPreviewProvider()
            .previewLayout(.sizeThatFits)
    }
    
    private struct PreviewUpdater: FilterUpdater {
        func updateUI(filterText: String) {
            print("filterText: \(filterText)")
        }
    }
}

protocol FilterUpdater {
    func updateUI(filterText: String)
}
