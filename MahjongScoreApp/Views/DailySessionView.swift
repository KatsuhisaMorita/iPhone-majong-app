import SwiftUI
import SwiftData

struct DailySessionView: View {
    let session: DailySession
    
    var body: some View {
        List {
            Section("Overview") {
                Text("Date: \(session.date.formatted(date: .abbreviated, time: .omitted))")
                Text("Games Played: \(session.games.count)")
            }
            
            Section("Total Scores for Today") {
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
            
            Section("Games") {
                ForEach(session.games.sorted(by: { $0.timestamp < $1.timestamp })) { game in
                    NavigationLink(destination: Text("Game Details (editable if needed)")) {
                        VStack(alignment: .leading) {
                            Text(game.timestamp.formatted(date: .omitted, time: .shortened))
                            // Simple summary
                            let records = game.playerScores.sorted(by: { $0.rank < $1.rank })
                            ForEach(records) { pScore in
                                HStack {
                                    Text("\(pScore.rank): \(pScore.player?.name ?? "Unknown")")
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
        .navigationTitle("Session Record")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GameInputView(session: session)) {
                    Text("New Game")
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
