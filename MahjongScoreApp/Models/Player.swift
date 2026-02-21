import SwiftData
import Foundation

@Model
final class Player {
    var id: UUID = UUID()
    var name: String = ""
    
    // Stats
    var totalGames: Int = 0
    var totalScore: Double = 0.0
    var firstPlaceCount: Int = 0
    var secondPlaceCount: Int = 0
    var thirdPlaceCount: Int = 0
    var fourthPlaceCount: Int = 0
    
    // Computed Properties
    var averageRank: Double {
        guard totalGames > 0 else { return 0.0 }
        let sum = (firstPlaceCount * 1) + (secondPlaceCount * 2) + (thirdPlaceCount * 3) + (fourthPlaceCount * 4)
        return Double(sum) / Double(totalGames)
    }
    
    var top2Rate: Double {
        guard totalGames > 0 else { return 0.0 }
        return Double(firstPlaceCount + secondPlaceCount) / Double(totalGames)
    }
    
    var lastPlaceAvoidanceRate: Double {
        guard totalGames > 0 else { return 0.0 }
        return Double(totalGames - fourthPlaceCount) / Double(totalGames)
    }

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
