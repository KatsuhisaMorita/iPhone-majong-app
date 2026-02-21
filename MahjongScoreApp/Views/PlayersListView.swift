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
                    Text("Total Games: \(player.totalGames) | Total Score: \(String(format: "%.1f", player.totalScore))")
                        .font(.subheadline)
                    Text("Avg Rank: \(String(format: "%.2f", player.averageRank)) | Top-2 Rate: \(String(format: "%.1f%%", player.top2Rate * 100))")
                        .font(.caption)
                    Text("Last Place Avoidance: \(String(format: "%.1f%%", player.lastPlaceAvoidanceRate * 100))")
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deletePlayers)
        }
        .navigationTitle("Players & Stats")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPlayer = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add New Player", isPresented: $showingAddPlayer) {
            TextField("Player Name", text: $newPlayerName)
            Button("Add") {
                let newPlayer = Player(name: newPlayerName)
                modelContext.insert(newPlayer)
                newPlayerName = ""
            }
            Button("Cancel", role: .cancel) {
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
