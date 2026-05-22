//
//  NusaLensApp.swift
//  NusaLens
//
//  Created by student on 22/05/26.
//

import SwiftUI
import FirebaseCore

@main
struct NusaLensApp: App {
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("Firebase GoogleService-Info.plist not found. Running in offline/mock data mode.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

