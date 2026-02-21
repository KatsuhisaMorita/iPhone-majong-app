import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySession.date, order: .reverse) private var sessions: [DailySession]
    
    @State private var showingSessionStart = false
    @State private var newlyCreatedSession: DailySession? = nil
    
    var body: some View {
        NavigationStack {
            List {
                Section("本日の対局") {
                    if let today = sessions.first(where: { Calendar.current.isDateInToday($0.date) }) {
                        NavigationLink("本日の対局を再開", destination: DailySessionView(session: today))
                        Button("新しい対局を開始") {
                            showingSessionStart = true
                        }
                    } else {
                        Button("本日の対局を開始") {
                            showingSessionStart = true
                        }
                    }
                }
                
                Section("過去の対局履歴") {
                    ForEach(sessions.filter { !Calendar.current.isDateInToday($0.date) }) { session in
                        NavigationLink(session.date.formatted(date: .abbreviated, time: .omitted), destination: DailySessionView(session: session))
                    }
                }
                
                Section("プレイヤー管理") {
                    NavigationLink("プレイヤーと成績", destination: PlayersListView())
                }
                
                Section("設定") {
                    NavigationLink("ルール設定", destination: SettingsView())
                }
            }
            .navigationTitle("麻雀スコア記録")
            .sheet(isPresented: $showingSessionStart) {
                SessionStartView { session in
                    newlyCreatedSession = session
                }
            }
            .navigationDestination(item: $newlyCreatedSession) { session in
                DailySessionView(session: session)
            }
        }
    }
}
