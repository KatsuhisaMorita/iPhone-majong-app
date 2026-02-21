import SwiftUI
import SwiftData

struct SessionChipInputView: View {
    let session: DailySession
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsArray: [RuleSettings]
    
    @State private var chipInputs: [String: Int] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("セッション終了チップ精算") {
                    Text("本日の最終的なチップ獲得枚数を入力してください。マイナスの場合は - を付けてください。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let players = session.players {
                        ForEach(players) { player in
                            Stepper("\(player.name): \(chipInputs[player.id.uuidString] ?? 0) 枚", 
                                    value: Binding(
                                        get: { self.chipInputs[player.id.uuidString] ?? 0 },
                                        set: { self.chipInputs[player.id.uuidString] = $0 }
                                    ))
                        }
                    }
                }
                
                Button("精算して終了") {
                    saveChips()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("チップ精算")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Initialize chip inputs with existing values if any, or 0
                if let players = session.players {
                    for player in players {
                        chipInputs[player.id.uuidString] = session.chipResults[player.id.uuidString] ?? 0
                    }
                }
            }
        }
    }
    
    private func saveChips() {
        guard let settings = settingsArray.first else { return }
        
        session.chipResults = chipInputs
        
        // Add chip points to total score of players
        if let players = session.players {
            for player in players {
                let chips = chipInputs[player.id.uuidString] ?? 0
                let chipPoints = Double(chips * settings.chipRate)
                player.totalScore += chipPoints
            }
        }
        
        dismiss()
    }
}
