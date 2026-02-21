# Mahjong Score App (iPhone)

iPhone用の直感的で機能的な麻雀点数記録アプリです。
Windows環境から `GitHub Actions` を経由してIPAファイルをビルドし、`Sideloadly` を使ってiPhone実機にデプロイすることを前提に作られています。

## 主な機能
- **スコア計算**: 25,000点持ち30,000点返し。五捨六入による精密な端数処理。
- **柔軟なルール**: ウマ・オカ、飛び賞（ボーナス/ペナルティ）、チップのカスタマイズ対応。
- **同着順位処理**: 席順（起家〜北家）による厳密な同点時の順位決め。
- **成績管理**: プレイヤーごとの通算成績（トータルスコア、平均順位、連対率、ラス回避率）、および1日単位でのセッションの記録。

## 開発・デプロイ手順（Windows向け）

このリポジトリは、Macを持たないWindowsユーザーのために、GitHub Actionsを利用してプロビジョニング・証明書不要（Unsigned）のIPAファイルを出力できるよう設定されています。

1. **コードのプッシュ**
   変更を `main` ブランチにコミット＆プッシュします。
   ```bash
   git add .
   git commit -m "Update app"
   git push origin main
   ```
2. **GitHub Actionsでのビルド**
   プッシュすると自動で `ios-build.yml` ワークフローが走り、数分で `MahjongScoreApp.ipa` が Artifacts として生成されます。
3. **iPhoneへのインストール (Sideloadly)**
   - Artifactsから `.zip` をダウンロードし解凍。
   - iPhoneをUSBでWindows PCに接続。
   - Sideloadlyを起動し、取得した `.ipa` をドラッグ＆ドロップして個人のApple IDで署名・インストールします。

## プロジェクトの設計ドキュメント
開発時の詳細な仕様や実装の一連のタスクについては、`docs/` ディレクトリの中に保管してあります。
- `docs/implementation_plan.md`: 実装計画・仕様
- `docs/task.md`: 開発タスクリスト
- `docs/walkthrough.md`: 実装完了後のサマリー
