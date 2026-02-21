# 麻雀点数記録アプリ タスクリスト

## 1. 企画・設計 (Planning)
- [x] 要件定義
- [x] データの持ち方、スコア計算ロジックの策定
- [x] 実装プランの作成と合意 (Implementation Plan)

## 2. プロジェクト基盤構築 (Setup)
- [x] 最小構成のXcodeプロジェクトとSwiftUIアプリ構造の作成 (`iPhone-majong-app`)
- [x] Windowsデプロイ用 GitHub Actions ワークフロー (`ios-build.yml`) の設定とInfo.plistの `CFBundleExecutable` 確認

## 3. データモデル実装 (Data Model)
- [x] SwiftData モデルの定義 (`Player`, `GameRecord`, `DailySession`, `RuleSettings`)
- [x] スコア計算ロジック (`ScoreCalculator`) の実装 (五捨六入、オカ、ウマ、飛び賞、同点時の上家優先処理)

## 4. UI/UX実装 (Views)
- [x] プレイヤー登録・選択画面の実装
- [x] ルール設定画面（基本設定とゲーム開始時のカスタマイズ）
- [x] 1ゲーム（半荘）の点数・チップ入力画面の実装（3人入力時の残1人自動計算、手動修正対応）
- [x] 1日のゲーム履歴（縦並び）と本日の合計スコア表示画面の実装
- [x] プレイヤーごとの通算成績表示画面の実装

## 5. テスト・検証 (Verification)
- [ ] スコア計算が要件通り正しく行われるかのテスト
- [ ] Windows -> GitHub Actions 経由でのIPAビルド検証
- [ ] 修正・微調整
