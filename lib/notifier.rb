require 'date'

# 通知の生成・管理を行うクラス
class Notifier
  attr_reader :date, :config

  def initialize(date, config)
    @date = date
    @config = config
  end

  # 通知メッセージの準備
  def prepare_notification
    {
      is_last_business_day: true,
      subject: generate_subject,
      body: generate_body,
      recipients: config.dig('email', 'recipients')
    }
  end

  # 環境変数用の出力を生成
  def generate_env_output
    recipients_str = config.dig('email', 'recipients').join(',')
    
    [
      "IS_LAST_BUSINESS_DAY=true",
      "EMAIL_SUBJECT=#{generate_subject}",
      "EMAIL_BODY=#{generate_body}",
      "EMAIL_TO=#{recipients_str}"
    ].join("\n")
  end

  private

  # 件名を生成
  def generate_subject
    "#{date.year}年#{date.month}月の月末のお知らせ"
  end

  # 本文を生成
  def generate_body
    "月末です"
  end
end