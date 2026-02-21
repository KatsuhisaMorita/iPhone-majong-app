# Mahjong Score App - Implementation Walkthrough

The initial setup, data model design, and core logic for the Mahjong Score App have been completed. Here is a summary of the accomplishments:

## 1. Project Initialization & GitHub Repository
- Initialized a git repository and linked it to `git@github.com:KatsuhisaMorita/iPhone-majong-app.git`.
- Configured the `.github/workflows/ios-build.yml` for Windows -> GitHub Actions -> Sideloadly unsigned IPA build pipeline.
- Created the foundational `MahjongScoreApp.xcodeproj/project.pbxproj` and `Info.plist`.

## 2. Core Logic (`ScoreCalculator`)
- **Go-sha Roku-nyu (五捨六入)**: Correctly converts points matching standard Mahjong rounding.
- **Dynamic Rules**: Supports customizable Uma (default 10-30 or 10-20), Tobi Bonus/Penalty, and Chip rates.
- **Tie-breaker**: Solved the fluctuating seat-order issue by explicitly asking for the Seat Order (1: East, 2: South, 3: West, 4: North) during score input. A smaller seat order number gives priority in tie-breaking.

## 3. Data Models (`SwiftData`)
- **Player**: Expanded with computed statistics (`averageRank`, `top2Rate`, `lastPlaceAvoidanceRate`).
- **GameRecord** & **PlayerGameScore**: Records individual score, chip counts, and dynamic ranks.
- **DailySession**: Aggregates games played on a specific day.
- **RuleSettings**: Stores configurable points.

## 4. UI Implementation (SwiftUI)
- `ContentView.swift`: Main dashboard separating Today's Session, Past Sessions, Player Stats, and Settings.
- `SettingsView.swift`: Editable defaults for rules.
- `PlayersListView.swift`: View all registered players and their computed career stats.
- `DailySessionView.swift`: A vertical list of the day's games, alongside the cumulative score of players for that day.
- `GameInputView.swift`: Form for entering raw scores, automatically calculates the 4th player's score from the remaining points, and assigns the correct rank taking tie-breakers into account.

### Validation 
Since this environment is Windows, the application requires building via GitHub Actions. We have prepared the CI/CD pipeline and the necessary code structure.

**Next Steps for the User**:
1. You can inspect the committed code. If the environment supports pushing to the repository, push this code to `main` to trigger the GitHub Action.
2. Download the `MahjongScoreApp.ipa` from the GitHub Actions Artifacts.
3. Use Sideloadly to install it on your iPhone and test the functionality!
