//
//  AirPlayView.swift
//  ClassicalPlayer2
//
//  Created by Frederick Kuhl on 1/7/21.
//

import SwiftUI
import AVKit

struct AirPlayView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {

        let routePickerView = AVRoutePickerView()
        routePickerView.backgroundColor = UIColor.clear

        return routePickerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
