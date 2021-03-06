//
//  SectionsAsSidebarView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 12/30/20.
//

import SwiftUI

struct RegularWidthView: View {
    @EnvironmentObject private var musicPlayer: MusicPlayer

    var body: some View {
        NavigationView {
            SidebarView()
            PiecesView(sort: .composer)  //the default choice
        }
        ///Sidebar nav shouldn't stack views.
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RegularWidthView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        RegularWidthView()
            .padding()
            .environment(\.managedObjectContext, context)
            .environmentObject(MusicPlayer())
            //doesn't actually go to landscape
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
            .previewLayout(.fixed(width: 1024, height: 768))
    }
}
