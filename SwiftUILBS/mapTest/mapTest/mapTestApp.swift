//
//  mapTestApp.swift
//  mapTest
//
//  Created by Junjie Li on 11/12/21.
//

import SwiftUI

@main
struct mapTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Location())
        }
    }
}
