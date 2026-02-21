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
            Section("ウマ設定") {
                Stepper("1位: +\(umaFirst)", value: $umaFirst)
                Stepper("2位: +\(umaSecond)", value: $umaSecond)
                Text("※ 3位は -\(umaSecond)、4位は -\(umaFirst) となります。\nワンスリーの場合は 10-30 を、ワンツーの場合は 10-20 を設定してください。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("飛び賞 (箱下)") {
                Toggle("飛び賞を有効にする", isOn: $isTobiEnabled)
                if isTobiEnabled {
                    Stepper("飛ばした人のボーナス: +\(tobiBonus)", value: $tobiBonus)
                    Stepper("飛んだ人のペナルティ: -\(tobiPenalty)", value: $tobiPenalty)
                }
            }
            
            Section("チップ") {
                Stepper("1枚あたりのスコア: \(chipRate)", value: $chipRate)
            }
        }
        .navigationTitle("ルール設定")
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
