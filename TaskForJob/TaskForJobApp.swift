//
//  TaskForJobApp.swift
//  TaskForJob
//
//  Created by PEPPA CHAN on 18.09.2024.
//

import SwiftUI

@main
struct TaskForJobApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}
