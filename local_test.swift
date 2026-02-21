import Foundation

// --- Mocks to replace SwiftData Models ---
class RuleSettings {
    var id: UUID = UUID()
    var targetScore: Int = 30000 
    var baseScore: Int = 25000 
    var umaFirst: Int = 30
    var umaSecond: Int = 10
    var isTobiEnabled: Bool = true
    var tobiBonus: Int = 10
    var tobiPenalty: Int = 10
    var chipRate: Int = 2
}

struct ScoreInput {
    var playerId: UUID
    var rawScore: Int
    var chipCount: Int
    var tieBreakerRank: Int?
}

struct ScoreResult {
    var playerId: UUID
    var finalScore: Double
    var rank: Int
}

// --- The Calculator (copied for tests to avoid SwiftData dependencies of the real project) ---
struct ScoreCalculator {
    static func calculate(inputs: [ScoreInput], settings: RuleSettings) throws -> [ScoreResult] {
        guard inputs.count == 4 else {
            throw NSError(domain: "ScoreCalculator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Require exactly 4 players"])
        }
        
        let totalRaw = inputs.map { $0.rawScore }.reduce(0, +)
        if totalRaw != settings.baseScore * 4 {
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
                }
                if i == 0 {
                    let tobiCount = preUmaScores.filter { $0.rawScore < 0 }.count
                    finalPoints += Double(tobiCount * settings.tobiBonus)
                }
            }
            
            // Apply Chips
            // Since user said chips are session-based now, we will test assuming chips are 0 for the game logic, but keep it here.
            finalPoints += Double(inputs.first(where: { $0.playerId == p.playerId })?.chipCount ?? 0) * Double(settings.chipRate)
            
            results.append(ScoreResult(playerId: p.playerId, finalScore: finalPoints, rank: i + 1))
        }
        
        return results
    }
    
    // 五捨六入 (Go-sha Roku-nyu)
    static func calculatePoints(rawScore: Int, targetScore: Int) -> Int {
        let diff = rawScore - targetScore
        
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

// --- Tests ---
func runTests() {
    let settings = RuleSettings()
    let p1 = UUID()
    let p2 = UUID()
    let p3 = UUID()
    let p4 = UUID()
    
    // Test Case 1: Standard case (40000, 30000, 20000, 10000)
    let inputs1 = [
        ScoreInput(playerId: p1, rawScore: 40000, chipCount: 0, tieBreakerRank: 1),
        ScoreInput(playerId: p2, rawScore: 30000, chipCount: 0, tieBreakerRank: 2),
        ScoreInput(playerId: p3, rawScore: 20000, chipCount: 0, tieBreakerRank: 3),
        ScoreInput(playerId: p4, rawScore: 10000, chipCount: 0, tieBreakerRank: 4)
    ]
    
    do {
        let results = try ScoreCalculator.calculate(inputs: inputs1, settings: settings)
        print("Test 1 (Standard):")
        for res in results.sorted(by: { $0.rank < $1.rank }) {
            print("Rank \(res.rank): Score \(res.finalScore)")
        }
        print("Expected: Rank 1: +60 (10 points + 20 oka + 30 uma), Rank 2: +10 (0 points + 10 uma), Rank 3: -20 (-10 points - 10 uma), Rank 4: -50 (-20 points - 30 uma)")
        print("-------------")
    } catch {
        print("Error: \(error)")
    }
    
    // Test Case 2: Tie breaking
    let inputs2 = [
        ScoreInput(playerId: p1, rawScore: 25000, chipCount: 0, tieBreakerRank: 4), // North
        ScoreInput(playerId: p2, rawScore: 25000, chipCount: 0, tieBreakerRank: 1), // East (Should win tie)
        ScoreInput(playerId: p3, rawScore: 25000, chipCount: 0, tieBreakerRank: 3), // West
        ScoreInput(playerId: p4, rawScore: 25000, chipCount: 0, tieBreakerRank: 2)  // South
    ]
    do {
        let results = try ScoreCalculator.calculate(inputs: inputs2, settings: settings)
        print("Test 2 (Tie Breaking - All 25000):")
        for res in results.sorted(by: { $0.rank < $1.rank }) {
            let pStr = res.playerId == p1 ? "North" : (res.playerId == p2 ? "East" : (res.playerId == p3 ? "West" : "South"))
            print("Rank \(res.rank): \(pStr) Score \(res.finalScore)")
        }
        print("-------------")
    } catch {
        print("Error: \(error)")
    }
}

runTests()
