import SwiftUI

@main
struct RemoteLogDemoApp: App {
    init() {
        HTTPServer.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
