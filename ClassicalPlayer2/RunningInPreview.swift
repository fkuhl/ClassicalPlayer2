//
//  RunningInPreview.swift
//  ClassicalPlayer
//
//  Created by Frederick Kuhl on 12/20/21.
//

import Foundation

func runningInPreview() -> Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
