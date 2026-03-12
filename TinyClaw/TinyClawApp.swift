import SwiftUI
import SwiftData

@main
struct TinyClawApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TaskItem.self, EventItem.self, Message.self])
    }
}
