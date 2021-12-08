//
//  View+debug.swift
//  PeriMeleon
//
//  Created by Frederick Kuhl on 12/18/20.
//

import SwiftUI


extension View {
    func debugPrint(_ value: Any) -> some View {
        #if DEBUG
        print(value)
        #endif
        return self
    }
}
