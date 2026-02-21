import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySession.date, order: .reverse) private var sessions: [DailySession]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Today's Session") {
                    if let today = sessions.first(where: { Calendar.current.isDateInToday($0.date) }) {
                        NavigationLink("Resume Today's Session", destination: DailySessionView(session: today))
                    } else {
                        Button("Start New Session Today") {
                            let newSession = DailySession(date: Date())
                            modelContext.insert(newSession)
                        }
                    }
                }
                
                Section("Past Sessions") {
                    ForEach(sessions.filter { !Calendar.current.isDateInToday($0.date) }) { session in
                        NavigationLink(session.date.formatted(date: .abbreviated, time: .omitted), destination: DailySessionView(session: session))
                    }
                }
                
                Section("Players & Stats") {
                    NavigationLink("Manage Players & View Stats", destination: PlayersListView())
                }
                
                Section("Settings") {
                    NavigationLink("Rule Settings", destination: SettingsView())
                }
            }
            .navigationTitle("Mahjong Score")
        }
    }
}
