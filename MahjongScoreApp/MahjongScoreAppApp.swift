import SwiftUI
import SwiftData

@main
struct MahjongScoreAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Player.self,
            DailySession.self,
            GameRecord.self,
            PlayerGameScore.self,
            RuleSettings.self
        ])
    }
}
