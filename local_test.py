import math
import uuid

class RuleSettings:
    def __init__(self):
        self.targetScore = 30000 
        self.baseScore = 25000 
        self.umaFirst = 30
        self.umaSecond = 10
        self.isTobiEnabled = True
        self.tobiBonus = 10
        self.tobiPenalty = 10
        self.chipRate = 2

class ScoreInput:
    def __init__(self, player_id, raw_score, chip_count, tie_breaker_rank=None):
        self.player_id = player_id
        self.raw_score = raw_score
        self.chip_count = chip_count
        self.tie_breaker_rank = tie_breaker_rank

class ScoreResult:
    def __init__(self, player_id, final_score, rank):
        self.player_id = player_id
        self.final_score = final_score
        self.rank = rank

# 五捨六入 (Go-sha Roku-nyu)
def calculate_points(raw_score, target_score):
    diff = raw_score - target_score
    remainder = abs(diff) % 1000
    points_base = int(diff / 1000) # Trucated division towards 0
    
    if diff >= 0:
        if remainder > 500:
            points_base += 1
    else:
        if remainder > 500:
            points_base -= 1
            
    return points_base

def calculate_scores(inputs, settings):
    if len(inputs) != 4:
        raise ValueError("Require exactly 4 players")
        
    total_raw = sum(i.raw_score for i in inputs)
    if total_raw != settings.baseScore * 4:
        print(f"Warning: Total score is {total_raw}, expects {settings.baseScore * 4}")
        
    # 1. Calculate points
    pre_uma_scores = []
    for inp in inputs:
        points = calculate_points(inp.raw_score, settings.targetScore)
        pre_uma_scores.append({
            "player_id": inp.player_id, 
            "points": points, 
            "raw_score": inp.raw_score, 
            "tie_breaker": inp.tie_breaker_rank,
            "chips": inp.chip_count
        })
        
    # 2. Sort
    # Sort primarily by raw_score descending, then by tie_breaker_rank ascending (lower is better, e.g. 1=East)
    def sort_key(x):
        return (-x["raw_score"], x["tie_breaker"] if x["tie_breaker"] is not None else 4)
    pre_uma_scores.sort(key=sort_key)
    
    # 3. Apply Oka, Uma, and Tobi
    results = []
    total_pre_uma = sum(p["points"] for p in pre_uma_scores)
    oka = -total_pre_uma
    
    umas = [settings.umaFirst, settings.umaSecond, -settings.umaSecond, -settings.umaFirst]
    
    for i, p in enumerate(pre_uma_scores):
        final_points = float(p["points"])
        
        # Apply Oka to 1st place
        if i == 0:
            final_points += oka
            
        # Apply Uma
        final_points += umas[i]
        
        # Apply Tobi
        if settings.isTobiEnabled:
            if p["raw_score"] < 0:
                final_points -= settings.tobiPenalty
            if i == 0:
                tobi_count = sum(1 for xp in pre_uma_scores if xp["raw_score"] < 0)
                final_points += (tobi_count * settings.tobiBonus)
                
        # Apply Chips (Even though we decided to move it to session level, 
        # this accurately reflects the current state of the calculator function for testing)
        final_points += p["chips"] * settings.chipRate
        
        results.append(ScoreResult(p["player_id"], final_points, i + 1))
        
    return results

def run_tests():
    settings = RuleSettings()
    p1, p2, p3, p4 = "A(北)", "B(東)", "C(西)", "D(南)"
    
    print("=== Test 1 (Standard 40000, 30000, 20000, 10000) ===")
    inputs1 = [
        ScoreInput(p1, 40000, 0, 4),
        ScoreInput(p2, 30000, 0, 1),
        ScoreInput(p3, 20000, 0, 3),
        ScoreInput(p4, 10000, 0, 2)
    ]
    results1 = calculate_scores(inputs1, settings)
    for r in sorted(results1, key=lambda x: x.rank):
        print(f"Rank {r.rank}: Player {r.player_id} Score {r.final_score}")
        
    print("\n=== Test 2 (Tie Breaking - All 25000) ===")
    inputs2 = [
        ScoreInput(p1, 25000, 0, 4), # North
        ScoreInput(p2, 25000, 0, 1), # East
        ScoreInput(p3, 25000, 0, 3), # West
        ScoreInput(p4, 25000, 0, 2)  # South
    ]
    results2 = calculate_scores(inputs2, settings)
    for r in sorted(results2, key=lambda x: x.rank):
        print(f"Rank {r.rank}: Player {r.player_id} Score {r.final_score}")

    print("\n=== Test 3 (五捨六入 check) ===")
    # 35500 -> 35.5 (0.5 ends in 500, but is > 500? wait, exact 500 round down)
    print("35400 -> Points:", calculate_points(35400, 30000), "Expected: 5")
    print("35500 -> Points:", calculate_points(35500, 30000), "Expected: 5 (500切り捨て)")
    print("35600 -> Points:", calculate_points(35600, 30000), "Expected: 6 (600切り上げ)")
    print("24600 -> Points:", calculate_points(24600, 30000), "Expected: -5 (差-5400 -> -5)")
    print("24500 -> Points:", calculate_points(24500, 30000), "Expected: -5 (差-5500 -> 切り捨てでゼロに近い-5)")
    print("24400 -> Points:", calculate_points(24400, 30000), "Expected: -6 (差-5600 -> 切り上げで-6)")
        

if __name__ == "__main__":
    run_tests()
