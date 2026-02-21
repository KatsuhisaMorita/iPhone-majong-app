import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [RuleSettings]
    
    @State private var settings: RuleSettings?
    
    @State private var umaFirst: Int = 30
    @State private var umaSecond: Int = 10
    @State private var isTobiEnabled: Bool = true
    @State private var tobiBonus: Int = 10
    @State private var tobiPenalty: Int = 10
    @State private var chipRate: Int = 2
    
    var body: some View {
        Form {
            Section("Uma (ウマ)") {
                Stepper("1st Place: +\(umaFirst)", value: $umaFirst)
                Stepper("2nd Place: +\(umaSecond)", value: $umaSecond)
                Text("Note: 3rd and 4th place will be -\(umaSecond) and -\(umaFirst). \nDefault 10-30 is One-Three (1st+30, 2nd+10). \nOne-Two is 10-20.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Tobi (飛び賞)") {
                Toggle("Enable Tobi", isOn: $isTobiEnabled)
                if isTobiEnabled {
                    Stepper("Tobi Bonus (for 1st): +\(tobiBonus)", value: $tobiBonus)
                    Stepper("Tobi Penalty (for busted): -\(tobiPenalty)", value: $tobiPenalty)
                }
            }
            
            Section("Chips (チップ)") {
                Stepper("Points per chip: \(chipRate)", value: $chipRate)
            }
        }
        .navigationTitle("Rule Settings")
        .onAppear {
            if let existing = settingsList.first {
                self.settings = existing
                self.umaFirst = existing.umaFirst
                self.umaSecond = existing.umaSecond
                self.isTobiEnabled = existing.isTobiEnabled
                self.tobiBonus = existing.tobiBonus
                self.tobiPenalty = existing.tobiPenalty
                self.chipRate = existing.chipRate
            } else {
                let newSettings = RuleSettings()
                modelContext.insert(newSettings)
                self.settings = newSettings
            }
        }
        .onChange(of: umaFirst) { settings?.umaFirst = umaFirst }
        .onChange(of: umaSecond) { settings?.umaSecond = umaSecond }
        .onChange(of: isTobiEnabled) { settings?.isTobiEnabled = isTobiEnabled }
        .onChange(of: tobiBonus) { settings?.tobiBonus = tobiBonus }
        .onChange(of: tobiPenalty) { settings?.tobiPenalty = tobiPenalty }
        .onChange(of: chipRate) { settings?.chipRate = chipRate }
    }
}
