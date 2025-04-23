# getsumatsu_kun (月末くん)

月末の最終営業日に通知を送信する自動ツールです。

## 概要

月末くんは、毎月の最終営業日を自動的に判定し、指定された宛先にメールで通知を送信するシンプルなツールです。GitHub Actionsを使用して定期的に実行され、祝日や土日を考慮して最終営業日を判定します。

## 機能

- 最終営業日の自動判定（土日祝日を除外）
- 指定した複数のメールアドレスに通知
- 通知履歴のログ記録
- GitHub Actionsでの定期実行

## インストール方法

```bash
# リポジトリをクローン
git clone https://github.com/nikuteresa/getsumatsu_kun.git
cd getsumatsu_kun

# 依存パッケージのインストール
bundle install
```

## 設定方法

### 設定ファイル

`config/settings.yml` ファイルで通知設定をカスタマイズできます：

```yaml
# メール設定
email:
  # 送信先メールアドレス（複数可）
  recipients:
    - user1@example.com
    - user2@example.com
  # 通知時間（HH:MM形式）
  default_time: "18:00"

# 将来的にSlack通知も追加予定
# slack:
#   webhook_url: "https://hooks.slack.com/services/xxxxx/yyyyy/zzzzz"
#   channel: "#general"
#   username: "月末くん"
```

### 設定項目の説明

| 設定項目 | 説明 | デフォルト値 |
|--------|-----|------------|
| `email.recipients` | メール通知の送信先（配列形式で複数指定可能） | `["default@example.com"]` |
| `email.default_time` | 通知時間 (HH:MM形式) | `"18:00"` |

### GitHub Secrets の設定

GitHub Actions でメール送信を行うには、以下の Secrets を設定する必要があります：

1. `MAIL_USERNAME`: メール送信に使用するアカウントのユーザー名
2. `MAIL_PASSWORD`: メール送信に使用するアカウントのパスワード（Gmailの場合はアプリパスワード）
3. `MAIL_FROM`: 送信元メールアドレス

GitHub リポジトリの Settings > Secrets and variables > Actions から設定できます。

## 使用方法

### 手動実行

```bash
# 月末かどうかの判定と通知（テスト用）
ruby main.rb
```

### 自動実行

GitHub Actions により、毎日JST 18:00に自動実行されます。最終営業日の場合のみ通知が送信されます。

手動で GitHub Actions ワークフローを実行するには、GitHub リポジトリの Actions タブから "Monthly End Notification" ワークフローを選択し、"Run workflow" ボタンをクリックします。

## テスト

テストは RSpec を使用して実装されています。テストを実行するには：

```bash
# すべてのテストを実行
bundle exec rspec

# 特定のテストファイルのみ実行
bundle exec rspec spec/lib/business_day_calculator_spec.rb

# テストカバレッジレポートを生成（結果は coverage/ ディレクトリに保存）
COVERAGE=true bundle exec rspec
```

### テスト構成

- `spec/lib/` - 各クラスの単体テスト
- `spec/support/` - テスト用のヘルパーメソッド

## ログ

通知履歴は `logs/notification_log.json` に記録されます。

## トラブルシューティング

### よくある問題

1. **通知が送信されない**
   - GitHub Secrets が正しく設定されているか確認
   - ログファイルで実行履歴を確認

2. **祝日判定が正しくない**
   - holiday_japan gemが最新かどうか確認（`bundle update`）

### デバッグ方法

```bash
# デバッグメッセージを表示して実行
ruby -d main.rb
```

## ドキュメント

- [要件定義書](doc/requirements.md)
- [設計ドキュメント](doc/design.md)

## ライセンス

MIT

## 貢献

バグ報告や機能要望は GitHub Issues にお願いします。プルリクエストも歓迎します。