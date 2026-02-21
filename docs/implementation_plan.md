# Goal Description

Windows環境からiPhone（実機）へデプロイ可能な、ローカル完結型の麻雀点数記録アプリを開発します。
25000点持ち30000点返し、ウマ・オカ、五捨六入、飛び賞、チップを考慮し、日々の対局ログや通算成績を記録・閲覧できる機能を提供します。

## 決定した仕様・ルール
- **スコア計算**: 25000点持ち30000点返し。トップ者に+20（オカ）。
- **ウマ**: デフォルト 10-30（ワンスリー）。開始時に変更可能。
- **飛び賞**: デフォルトあり（飛ばした人+10, 飛んだ人-10）。開始時に変更可能。
- **端数処理**: 五捨六入（500点は切り捨て、600点を切り上げへ）。
- **同着処理**: 上家（東・南・西・北の順）を上位とする。
- **チップ**: デフォルト1枚2ポイント。開始時に設定可能。
- **入力UI**: 3人分の点数を入力すると残り1人を自動計算（自動計算されたものも手動修正可能）。
- **表示**:
  - 1日分の記録が縦に並び、一番下に当日のトータルスコアを表示。チップも集計。
  - プレイヤーごとの通算成績（トータルスコアなど）を閲覧可能機能。
- **データ管理**: SwiftDataによるローカル完結。アカウント不要。

## User Review Required

> [!IMPORTANT]
> - 本アプリはWindows環境でのデプロイを前提とするため、以前確認した `ios-build.yml` を利用してIPAファイルを出力する構成にします。
> - SwiftDataとSwiftUIを用いて構築します。プロジェクト名は `MahjongScoreApp` などを想定していますが、指定があれば教えてください。
> - 「上家優先」を実現するため、ゲーム開始時に各プレイヤーの**席順（起家から順に東・南・西・北）を事前に決めてから入力**するUIとします（同点時の判定に必須となるため）。問題ないでしょうか？

## Proposed Changes

開発は以下の構成で進めます。

---

### アプリ基盤・CI/CD
Windowsからのデプロイに向けたワークフローやプロジェクトのベース設定。

#### [NEW] `c:/work/AIDLC/iPhone-majong-app/.github/workflows/ios-build.yml`
Windowsデプロイ用の署名なしビルドを出力するGitHub Actionsワークフロー。
#### [NEW] `c:/work/AIDLC/iPhone-majong-app/MahjongScoreApp.xcodeproj/project.pbxproj`
最小構成のXcodeプロジェクト定義。

---

### データモデル (SwiftData) と ロジック
スコア計算のコアとデータの永続化。

#### [NEW] `Models/Player.swift`
プレイヤーの名前や通算成績を計算するための情報を保持。
#### [NEW] `Models/GameRecord.swift` & `Models/DailySession.swift`
1半荘のスコア・チップの記録モデルと、それをまとめる1日（セッション）のモデル。
#### [NEW] `Models/RuleSettings.swift`
ウマ、飛び賞の有無、チップレートなどの設定モデル。
#### [NEW] `Logic/ScoreCalculator.swift`
点数からスコアを算出するロジック。五捨六入、ウマ・オカ、同着時の上家優先処理をカプセル化。

---

### UI コンポーネント
SwiftUIによる画面群。

#### [NEW] `Views/ContentView.swift`
アプリのエントリーポイント。本日のセッション、過去の成績一覧へのナビゲーション。
#### [NEW] `Views/DailySessionView.swift`
1日ごとの記録を縦並びで表示、合計スコア・チップを算出する画面。
#### [NEW] `Views/GameInputView.swift`
点数入力、3人入力時点での残点数自動補完、席順の設定、チップ入力を行う画面。
#### [NEW] `Views/SettingsView.swift`
デフォルトルールの設定画面。

## Verification Plan

### Automated Tests
- `ScoreCalculator` の単体テストを作成し、五捨六入や同点時（上家優先）、飛び賞等のエッジケースが正しく計算されるか検証します。（必要に応じてSwiftのTestターゲットを構成するかロジック検証スクリプトを用意します）

### Manual Verification
- GitHub Actionsによるビルドが成功し、生成された `MahjongScoreApp.ipa` が Sideloadly で実機にインストール・起動できることを確認していただきます。
- 画面上でプレイヤー登録〜点数入力〜自動計算〜結果のリスト表示 が正しく行えるか検証していただきます。
