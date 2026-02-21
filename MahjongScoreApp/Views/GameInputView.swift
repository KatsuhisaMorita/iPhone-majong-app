import SwiftUI
import SwiftData

struct GameScoreInput: Identifiable {
    let id = UUID()
    var player: Player?
    var scoreString: String = ""
    var chips: Int = 0
    var seatOrder: Int = 1
}

struct GameInputView: View {
    let session: DailySession
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var players: [Player]
    @Query private var settingsArray: [RuleSettings]
    
    @State private var inputs: [GameScoreInput] = [
        GameScoreInput(seatOrder: 1),
        GameScoreInput(seatOrder: 2),
        GameScoreInput(seatOrder: 3),
        GameScoreInput(seatOrder: 4)
    ]
    
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section("入力支援") {
                Text("3人の点数を入力すると、4人目の点数は自動計算されます。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(0..<4, id: \.self) { index in
                Section("プレイヤー \(index + 1)") {
                    Picker("プレイヤー選択", selection: $inputs[index].player) {
                        Text("未選択").tag(Player?.none)
                        ForEach(players) { p in
                            Text(p.name).tag(Player?.some(p))
                        }
                    }
                    
                    Picker("席順 (同着時の判定用)", selection: $inputs[index].seatOrder) {
                        Text("1: 東 (起家)").tag(1)
                        Text("2: 南").tag(2)
                        Text("3: 西").tag(3)
                        Text("4: 北").tag(4)
                    }
                    
                    TextField("持ち点 (例: 25000)", text: $inputs[index].scoreString)
                        .keyboardType(.numberPad)
                        .onChange(of: inputs[index].scoreString) { _ in
                            autoCalculate4th()
                        }
                    
                    Stepper("チップ獲得枚数: \(inputs[index].chips)", value: $inputs[index].chips)
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
            .disabled(inputs.contains(where: { $0.player == nil }) || inputs.contains(where: { Int($0.scoreString) == nil }))
        }
        .navigationTitle("新規半荘入力")
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
    
    private func saveGame() {
        guard let settings = settingsArray.first else { return }
        
        let rawScores = inputs.map { Int($0.scoreString) ?? 0 }
        let total = rawScores.reduce(0, +)
        if total != settings.baseScore * 4 {
            errorMessage = "4人の合計点が \(settings.baseScore * 4) 点になるようにしてください。（現在: \(total)点）"
            return
        }
        
        let playerIds = inputs.compactMap { $0.player?.id }
        if Set(playerIds).count != 4 {
            errorMessage = "4人の異なるプレイヤーを選択してください。"
            return
        }
        
        let seats = inputs.map { $0.seatOrder }
        if Set(seats).count != 4 {
            errorMessage = "席順（起家〜北家）はそれぞれ異なるものを選択してください。"
            return
        }
        
        let scoreInputs = inputs.map { input in
            ScoreInput(
                playerId: input.player!.id,
                rawScore: Int(input.scoreString)!,
                chipCount: input.chips,
                tieBreakerRank: input.seatOrder
            )
        }
        
        do {
            let results = try ScoreCalculator.calculate(inputs: scoreInputs, settings: settings)
            
            let game = GameRecord(timestamp: Date())
            modelContext.insert(game)
            game.dailySession = session
            
            for (i, input) in inputs.enumerated() {
                let p = input.player!
                let result = results.first(where: { $0.playerId == p.id })!
                
                let gameScore = PlayerGameScore(
                    player: p,
                    rawScore: Int(input.scoreString)!,
                    seatOrder: input.seatOrder,
                    chipCount: input.chips
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
