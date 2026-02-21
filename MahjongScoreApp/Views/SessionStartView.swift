import SwiftUI
import SwiftData

struct SessionStartView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allPlayers: [Player]
    
    @State private var selectedPlayers: [Player?] = [nil, nil, nil, nil]
    @State private var errorMessage = ""
    
    var onSessionStarted: ((DailySession) -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("参加プレイヤーの選択") {
                    ForEach(0..<4, id: \.self) { index in
                        Picker("プレイヤー \(index + 1)", selection: $selectedPlayers[index]) {
                            Text("未選択").tag(Player?.none)
                            ForEach(allPlayers) { p in
                                Text(p.name).tag(Player?.some(p))
                            }
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red)
                }
                
                Button("このメンバーで対局開始") {
                    startSession()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(selectedPlayers.contains(where: { $0 == nil }))
            }
            .navigationTitle("メンバー選択")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startSession() {
        let players = selectedPlayers.compactMap { $0 }
        let uniquePlayers = Set(players.map { $0.id })
        
        if uniquePlayers.count != 4 {
            errorMessage = "4人の異なるプレイヤーを選択してください。"
            return
        }
        
        let newSession = DailySession(date: Date(), players: players)
        modelContext.insert(newSession)
        
        dismiss()
        onSessionStarted?(newSession)
    }
}
