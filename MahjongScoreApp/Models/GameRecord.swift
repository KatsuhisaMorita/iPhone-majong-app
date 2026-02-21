import SwiftData
import Foundation

@Model
final class PlayerGameScore {
    var id: UUID = UUID()
    var game: GameRecord?
    
    @Relationship(deleteRule: .nullify)
    var player: Player?
    
    var rawScore: Int = 0
    var finalScore: Double = 0.0
    var rank: Int = 1
    var chipCount: Int = 0
    
    // Added for tie-breaker prompt indicating seat priority explicitly
    var seatOrder: Int = 0 // 1: East, 2: South, 3: West, 4: North
    
    init(player: Player?, rawScore: Int, seatOrder: Int, chipCount: Int = 0) {
        self.id = UUID()
        self.player = player
        self.rawScore = rawScore
        self.seatOrder = seatOrder
        self.chipCount = chipCount
    }
}

@Model
final class GameRecord {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var dailySession: DailySession?
    
    @Relationship(deleteRule: .cascade, inverse: \PlayerGameScore.game)
    var playerScores: [PlayerGameScore] = []
    
    init(timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
    }
}
