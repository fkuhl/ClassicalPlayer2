//
//  CheckboxToggleStyle.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 10/23/20.
//

import SwiftUI

//https://swiftwithmajid.com/2020/03/04/customizing-toggle-in-swiftui/

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            //configuration.label
            //Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
