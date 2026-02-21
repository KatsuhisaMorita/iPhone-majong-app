import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySession.date, order: .reverse) private var sessions: [DailySession]
    
    var body: some View {
        NavigationStack {
            List {
                Section("本日の対局") {
                    if let today = sessions.first(where: { Calendar.current.isDateInToday($0.date) }) {
                        NavigationLink("本日の対局を再開", destination: DailySessionView(session: today))
                        Button("新しい対局を開始") {
                            let newSession = DailySession(date: Date())
                            modelContext.insert(newSession)
                        }
                    } else {
                        Button("本日の対局を開始") {
                            let newSession = DailySession(date: Date())
                            modelContext.insert(newSession)
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
        }
    }
}
