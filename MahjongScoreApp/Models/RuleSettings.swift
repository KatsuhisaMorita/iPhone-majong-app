import SwiftData
import Foundation

@Model
final class RuleSettings {
    var id: UUID = UUID()
    var targetScore: Int = 30000 // 30000点返し
    var baseScore: Int = 25000 // 25000点持ち
    
    // Uma is an array, e.g., [10, 30] means 1st gets +30, 2nd gets +10, 3rd gets -10, 4th gets -30
    var umaFirst: Int = 30
    var umaSecond: Int = 10
    
    var isTobiEnabled: Bool = true // 飛び賞の有無
    var tobiBonus: Int = 10 // 飛ばした人が+10
    var tobiPenalty: Int = 10 // 飛んだ人が-10
    
    var chipRate: Int = 2 // チップ1枚あたりのスコア
    
    init() {
        self.id = UUID()
    }
}
