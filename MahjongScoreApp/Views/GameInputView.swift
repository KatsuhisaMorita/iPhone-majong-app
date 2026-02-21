import SwiftUI
import SwiftData

struct GameScoreInput: Identifiable {
    let id = UUID()
    var player: Player
    var scoreString: String = ""
    var seatOrder: Int = 1 // Only used if tied
}

struct GameInputView: View {
    let session: DailySession
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsArray: [RuleSettings]
    
    @State private var inputs: [GameScoreInput] = []
    @State private var errorMessage = ""
    @State private var needsTieBreaker = false
    
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section("入力支援") {
                Text("3人の点数を入力すると、4人目の点数は自動計算されます。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(0..<inputs.count, id: \.self) { index in
                Section(inputs[index].player.name) {
                    TextField("持ち点 (例: 25000)", text: $inputs[index].scoreString)
                        .keyboardType(.numberPad)
                        .onChange(of: inputs[index].scoreString) { _ in
                            autoCalculate4th()
                            checkTieBreaker()
                        }
                    
                    if needsTieBreaker {
                        Picker("席順 (同着時の判定用)", selection: $inputs[index].seatOrder) {
                            Text("1: 東 (起家)").tag(1)
                            Text("2: 南").tag(2)
                            Text("3: 西").tag(3)
                            Text("4: 北").tag(4)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
            
            Button("半荘成績を保存") {
                saveGame()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(inputs.contains(where: { Int($0.scoreString) == nil }))
        }
        .navigationTitle("新規半荘入力")
        .onAppear {
            if inputs.isEmpty, let sessionPlayers = session.players, sessionPlayers.count == 4 {
                inputs = sessionPlayers.enumerated().map { (index, p) in
                    GameScoreInput(player: p, seatOrder: index + 1)
                }
            }
        }
    }
    
    private func autoCalculate4th() {
        let validScores = inputs.compactMap { Int($0.scoreString) }
        let emptyCount = inputs.filter { $0.scoreString.isEmpty }.count
        
        if validScores.count == 3 && emptyCount == 1 {
            let total = validScores.reduce(0, +)
            let settings = settingsArray.first ?? RuleSettings()
            let requiredTotal = settings.baseScore * 4
            let missing = requiredTotal - total
            
            if let index = inputs.firstIndex(where: { $0.scoreString.isEmpty }) {
                inputs[index].scoreString = "\(missing)"
            }
        }
    }
    
    private func checkTieBreaker() {
        let scores = inputs.compactMap { Int($0.scoreString) }
        let uniqueScores = Set(scores)
        // If there are duplicate valid scores, we need tie breaker
        needsTieBreaker = (scores.count == 4 && uniqueScores.count < 4)
    }
    
    private func saveGame() {
        guard let settings = settingsArray.first else { return }
        
        let rawScores = inputs.map { Int($0.scoreString) ?? 0 }
        let total = rawScores.reduce(0, +)
        if total != settings.baseScore * 4 {
            errorMessage = "4人の合計点が \(settings.baseScore * 4) 点になるようにしてください。（現在: \(total)点）"
            return
        }
        
        if needsTieBreaker {
            let seats = inputs.map { $0.seatOrder }
            if Set(seats).count != 4 {
                errorMessage = "同着が発生しています。席順（起家〜北家）はそれぞれ異なるものを選択してください。"
                return
            }
        }
        
        // Chip count is now processed at session end, so pass 0 per game
        let scoreInputs = inputs.map { input in
            ScoreInput(
                playerId: input.player.id,
                rawScore: Int(input.scoreString)!,
                chipCount: 0,
                tieBreakerRank: needsTieBreaker ? input.seatOrder : nil
            )
        }
        
        do {
            let results = try ScoreCalculator.calculate(inputs: scoreInputs, settings: settings)
            
            let game = GameRecord(timestamp: Date())
            modelContext.insert(game)
            game.dailySession = session
            
            for input in inputs {
                let p = input.player
                let result = results.first(where: { $0.playerId == p.id })!
                
                let gameScore = PlayerGameScore(
                    player: p,
                    rawScore: Int(input.scoreString)!,
                    seatOrder: needsTieBreaker ? input.seatOrder : nil
                )
                gameScore.finalScore = result.finalScore
                gameScore.rank = result.rank
                
                modelContext.insert(gameScore)
                game.playerScores.append(gameScore)
                
                p.totalGames += 1
                p.totalScore += result.finalScore
                switch result.rank {
                case 1: p.firstPlaceCount += 1
                case 2: p.secondPlaceCount += 1
                case 3: p.thirdPlaceCount += 1
                case 4: p.fourthPlaceCount += 1
                default: break
                }
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
