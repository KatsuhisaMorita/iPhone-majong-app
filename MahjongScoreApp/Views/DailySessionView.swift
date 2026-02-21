import SwiftUI
import SwiftData

struct DailySessionView: View {
    let session: DailySession
    
    var body: some View {
        List {
            Section("概要") {
                Text("日付: \(session.date.formatted(date: .abbreviated, time: .omitted))")
                Text("プレイ数: \(session.games.count) 半荘")
            }
            
            Section("本日の合計成績") {
                let totals = calculateDailyTotals(for: session)
                ForEach(totals.sorted(by: { $0.value > $1.value }), id: \.key.id) { player, score in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(String(format: "%.1f", score))
                            .foregroundColor(score >= 0 ? .red : .blue)
                    }
                }
            }
            
            Section("半荘履歴") {
                ForEach(session.games.sorted(by: { $0.timestamp < $1.timestamp })) { game in
                    NavigationLink(destination: Text("詳細 (将来拡張用)")) {
                        VStack(alignment: .leading) {
                            Text(game.timestamp.formatted(date: .omitted, time: .shortened))
                            // Simple summary
                            let records = game.playerScores.sorted(by: { $0.rank < $1.rank })
                            ForEach(records) { pScore in
                                HStack {
                                    Text("\(pScore.rank)位: \(pScore.player?.name ?? "不明")")
                                    Spacer()
                                    Text(String(format: "%.1f", pScore.finalScore))
                                        .foregroundColor(pScore.finalScore >= 0 ? .red : .blue)
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("本日の対局")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GameInputView(session: session)) {
                    Text("新規半荘入力")
                }
            }
        }
    }
    
    private func calculateDailyTotals(for session: DailySession) -> [Player: Double] {
        var totals = [Player: Double]()
        for game in session.games {
            for score in game.playerScores {
                if let p = score.player {
                    totals[p, default: 0.0] += score.finalScore
                }
            }
        }
        return totals
    }
}
