# tukimatsu_chan (月末ちゃん)

月末の最終営業日を判定するGitHub Actionです。
Claude Desktop を使用して作成しています。

## 概要

月末ちゃんは、今日が月末の最終営業日（祝日や土日を除く）かどうかを判定するシンプルなGitHub Actionです。GitHub Actionsワークフローで利用でき、ワークフローの条件分岐などに活用できます。

## 機能

- 最終営業日の自動判定（土日祝日を除外）
- 日本の祝日に対応（[holiday_japan](https://github.com/komagata/holiday_japan) gemを使用）

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
        uses: nikuteresa/tukimatsu_chan@v0.1.2
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
    uses: nikuteresa/tukimatsu_chan@v0.1.2
    id: month_end

  - name: 月末の場合のみ実行
    if: steps.month_end.outputs.is_last_business_day == 'true'
    run: echo "月末の処理を実行します"
```

## 謝辞

- 日本の祝日判定には [holiday_japan](https://github.com/komagata/holiday_japan) gemを使用しています

## ライセンス

MIT
