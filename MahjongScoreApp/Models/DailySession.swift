import SwiftData
import Foundation

@Model
final class DailySession {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \GameRecord.dailySession)
    var games: [GameRecord] = []
    
    // The 4 players who are participating in this session
    @Relationship(deleteRule: .nullify)
    var players: [Player]? = []
    
    // Chips collected at the end of the session
    // Mapping player ID (UUID string) to chip count
    var chipResults: [String: Int] = [:]
    
    init(date: Date = Date(), players: [Player] = []) {
        self.id = UUID()
        self.date = date
        self.players = players
    }
}
