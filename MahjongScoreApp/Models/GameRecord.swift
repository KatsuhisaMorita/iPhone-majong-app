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
    
    // Seat order is only needed if there was a tie to break. Optional.
    var seatOrder: Int? = nil 
    
    init(player: Player?, rawScore: Int, seatOrder: Int? = nil) {
        self.id = UUID()
        self.player = player
        self.rawScore = rawScore
        self.seatOrder = seatOrder
        self.chipCount = 0 // Chips moved to session, kept here 0 for backward logic compatibility if needed or removed
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
