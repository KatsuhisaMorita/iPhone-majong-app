import Foundation

struct ScoreInput {
    var playerId: UUID
    var rawScore: Int
    var chipCount: Int
    var tieBreakerRank: Int? // 1: higher priority, 2: lower priority, etc.
}

struct ScoreResult {
    var playerId: UUID
    var finalScore: Double
    var rank: Int
}

struct ScoreCalculator {
    static func calculate(inputs: [ScoreInput], settings: RuleSettings) throws -> [ScoreResult] {
        guard inputs.count == 4 else {
            throw NSError(domain: "ScoreCalculator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Require exactly 4 players"])
        }
        
        let totalRaw = inputs.map { $0.rawScore }.reduce(0, +)
        if totalRaw != settings.baseScore * 4 {
            // throw NSError(domain: "ScoreCalculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Total score is not \(settings.baseScore * 4)"])
            // For now, allow it or ensure it in UI.
        }
        
        // 1. Calculate points after 30000 return and rounding (五捨六入)
        var preUmaScores: [(playerId: UUID, points: Int, rawScore: Int, tieBreaker: Int?)] = inputs.map { input in
            let points = calculatePoints(rawScore: input.rawScore, targetScore: settings.targetScore)
            return (input.playerId, points, input.rawScore, input.tieBreakerRank)
        }
        
        // 2. Sort by rawScore descending, then tieBreakerRank ascending
        preUmaScores.sort { a, b in
            if a.rawScore != b.rawScore {
                return a.rawScore > b.rawScore
            }
            // lower tieBreakerRank means higher priority
            return (a.tieBreaker ?? 4) < (b.tieBreaker ?? 4)
        }
        
        // 3. Apply Oka, Uma, and Tobi
        var results = [ScoreResult]()
        let totalPreUmaPoints = preUmaScores.map { $0.points }.reduce(0, +)
        let oka = -totalPreUmaPoints // The missing points (usually +20 for 1st place)
        
        let umas = [settings.umaFirst, settings.umaSecond, -settings.umaSecond, -settings.umaFirst]
        
        for (i, p) in preUmaScores.enumerated() {
            var finalPoints = Double(p.points)
            
            // Apply Oka to 1st place
            if i == 0 {
                finalPoints += Double(oka)
            }
            
            // Apply Uma
            finalPoints += Double(umas[i])
            
            // Apply Tobi (if rawScore < 0)
            if settings.isTobiEnabled {
                if p.rawScore < 0 {
                    finalPoints -= Double(settings.tobiPenalty)
                    // The 1st place gets the Tobi bonus
                    // (Assuming 1st place gets it, or should it be the one who caused it? Usually 1st place gets the overall Tobi bonus)
                }
                if i == 0 {
                    let tobiCount = preUmaScores.filter { $0.rawScore < 0 }.count
                    finalPoints += Double(tobiCount * settings.tobiBonus)
                }
            }
            
            // Apply Chips
            finalPoints += Double(inputs.first(where: { $0.playerId == p.playerId })?.chipCount ?? 0) * Double(settings.chipRate)
            
            results.append(ScoreResult(playerId: p.playerId, finalScore: finalPoints, rank: i + 1))
        }
        
        // Final sanity check: Total should be 0 (excluding chips)
        // Note: chips might make total non-zero if total chips != 0.
        
        return results
    }
    
    // 五捨六入 (Go-sha Roku-nyu)
    static func calculatePoints(rawScore: Int, targetScore: Int) -> Int {
        let diff = rawScore - targetScore
        
        // -4500 -> remainder -500. 
        let remainder = abs(diff) % 1000
        var pointsBase = diff / 1000
        
        if diff >= 0 {
            if remainder > 500 {
                pointsBase += 1
            }
        } else {
            if remainder > 500 {
                pointsBase -= 1
            }
        }
        
        return pointsBase
    }
}
