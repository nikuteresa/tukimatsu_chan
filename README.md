# getsumatsu_chan (月末ちゃん)

月末の最終営業日を判定するGitHub Actionです。

## 概要

月末ちゃんは、今日が月末の最終営業日（祝日や土日を除く）かどうかを判定するシンプルなGitHub Actionです。GitHub Actionsワークフローで利用でき、ワークフローの条件分岐などに活用できます。

## アーキテクチャ

月末ちゃんは単一の責務に特化したアクションです：

**月末判定アクション** - 今日が月末の最終営業日かどうかを判定します（`action.yml`として実装）

このシンプルな設計により、さまざまなワークフローに組み込みやすくなっています。

## 機能

- 最終営業日の自動判定（土日祝日を除外）
- 日本の祝日に対応
- 柔軟なワークフロー連携
- 明確な出力フォーマット

## インストール方法

GitHub Actionsワークフローで直接使用できます。リポジトリのクローンは不要です。

```yaml
# ワークフローの例
name: 月末チェック

on:
  schedule:
    - cron: '0 9 * * *'  # UTC 9:00 = JST 18:00
  workflow_dispatch:  # 手動実行用

jobs:
  check-month-end:
    runs-on: ubuntu-latest
    steps:
      - name: 月末判定
        uses: nikuteresa/getsumatsu_chan@v1
        id: month_end

      - name: 結果表示
        run: |
          echo "最終営業日？: ${{ steps.month_end.outputs.is_last_business_day }}"
          echo "日付: ${{ steps.month_end.outputs.executed_at }}"

      - name: 月末の場合のみ実行
        if: steps.month_end.outputs.is_last_business_day == 'true'
        run: echo "月末の処理を実行します"
```

## 出力パラメータ

| 出力名 | 説明 | 例 |
|-------|------|----| 
| `is_last_business_day` | 今日が月末の最終営業日であれば `true`、そうでなければ `false` | `true` |
| `executed_at` | 実行時の日付（日本語形式） | `2025年4月30日` |

## 使用例

### 基本的な使用方法

```yaml
steps:
  - name: 月末判定
    uses: nikuteresa/getsumatsu_chan@v1
    id: month_end

  - name: 月末の場合のみ実行
    if: steps.month_end.outputs.is_last_business_day == 'true'
    run: echo "月末の処理を実行します"
```

## 応用例

### 月末レポートの自動生成

```yaml
name: 月末レポート生成

on:
  schedule:
    - cron: '0 9 * * *'  # UTC 9:00 = JST 18:00

jobs:
  generate-report:
    runs-on: ubuntu-latest
    steps:
      - name: リポジトリのチェックアウト
        uses: actions/checkout@v3

      - name: 月末判定
        uses: nikuteresa/getsumatsu_chan@v1
        id: month_end

      - name: レポート生成
        if: steps.month_end.outputs.is_last_business_day == 'true'
        run: |
          echo "## ${{ steps.month_end.outputs.executed_at }} 月次レポート" > report.md
          echo "月末処理が完了しました" >> report.md
        
      - name: レポートのコミット
        if: steps.month_end.outputs.is_last_business_day == 'true'
        uses: EndBug/add-and-commit@v9
        with:
          add: 'report.md'
          message: '${{ steps.month_end.outputs.executed_at }} 月次レポート'
```

### Slack通知との連携

```yaml
name: 月末Slack通知

on:
  schedule:
    - cron: '0 9 * * *'  # UTC 9:00 = JST 18:00

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: 月末判定
        uses: nikuteresa/getsumatsu_chan@v1
        id: month_end

      - name: Slack通知
        if: steps.month_end.outputs.is_last_business_day == 'true'
        uses: slackapi/slack-github-action@v1.23.0
        with:
          payload: |
            {
              "text": "${{ steps.month_end.outputs.executed_at }} - 今日は月末です！"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## 開発者向け情報

### 動作環境

- Ruby 3.2以上
- 日本の祝日判定には `holiday_japan` gemを使用

### テスト

RSpecによるテストが実装されています。

```bash
# すべてのテストを実行
bundle exec rspec

# テストカバレッジレポートを生成
COVERAGE=true bundle exec rspec
```

### トラブルシューティング

#### よくある問題

1. **祝日判定が正しくない**
   - holiday_japan gemが最新かどうか確認（`bundle update`）

2. **GitHub Actionsでエラーが発生する**
   - Rubyバージョンの互換性を確認
   - ワークフローのログで詳細を確認

#### デバッグ方法

ローカル環境でテストする場合：

```bash
# デバッグメッセージを表示して実行
ruby -d bin/determine_month_end.rb
```

## 謝辞

- 日本の祝日判定には [holiday_japan](https://github.com/komagata/holiday_japan) gemを使用しています

## ライセンス

MIT

## 貢献

バグ報告や機能要望は GitHub Issues にお願いします。プルリクエストも歓迎します。