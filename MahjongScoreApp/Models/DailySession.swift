import SwiftData
import Foundation

@Model
final class DailySession {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \GameRecord.dailySession)
    var games: [GameRecord] = []
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}
