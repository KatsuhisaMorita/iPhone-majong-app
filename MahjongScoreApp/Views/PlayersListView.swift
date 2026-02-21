import SwiftUI
import SwiftData

struct PlayersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.name) private var players: [Player]
    
    @State private var showingAddPlayer = false
    @State private var newPlayerName = ""
    
    var body: some View {
        List {
            ForEach(players) { player in
                VStack(alignment: .leading) {
                    Text(player.name).font(.headline)
                    Text("対局数: \(player.totalGames)半荘 | 累計スコア: \(String(format: "%.1f", player.totalScore))")
                        .font(.subheadline)
                    Text("平均順位: \(String(format: "%.2f", player.averageRank)) | 連対率 (Top-2): \(String(format: "%.1f%%", player.top2Rate * 100))")
                        .font(.caption)
                    Text("ラス回避率: \(String(format: "%.1f%%", player.lastPlaceAvoidanceRate * 100))")
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deletePlayers)
        }
        .navigationTitle("プレイヤー実績")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPlayer = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("新規プレイヤー追加", isPresented: $showingAddPlayer) {
            TextField("名前", text: $newPlayerName)
            Button("追加") {
                let newPlayer = Player(name: newPlayerName)
                modelContext.insert(newPlayer)
                newPlayerName = ""
            }
            Button("キャンセル", role: .cancel) {
                newPlayerName = ""
            }
        }
    }
    
    private func deletePlayers(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(players[index])
        }
    }
}
