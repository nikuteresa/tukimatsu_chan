#!/usr/bin/env ruby

require 'date'
require 'json'
require 'yaml'
require 'fileutils'
require_relative 'lib/business_day_calculator'

# ログディレクトリが存在しない場合は作成
FileUtils.mkdir_p('logs') unless Dir.exist?('logs')

# 設定ファイルの読み込み
begin
  config = YAML.load_file('config/settings.yml')
rescue Errno::ENOENT
  # 設定ファイルがない場合はデフォルト設定を使用
  config = {
    'email' => {
      'recipients' => ['default@example.com'],
      'default_time' => '18:00'
    }
  }
  
  # デフォルト設定ファイルを作成
  FileUtils.mkdir_p('config') unless Dir.exist?('config')
  File.open('config/settings.yml', 'w') do |file|
    file.write(config.to_yaml)
  end
end

# 実行日の取得
today = Date.today
calculator = BusinessDayCalculator.new

# 今日が当月の最終営業日かどうか確認
if calculator.last_business_day_of_current_month?(today)
  # 最終営業日の場合、環境変数を設定してGitHub Actionsで使用
  puts "IS_LAST_BUSINESS_DAY=true"
  
  # 通知用の情報を設定
  year = today.year
  month = today.month
  puts "EMAIL_SUBJECT=#{year}年#{month}月の月末のお知らせ"
  puts "EMAIL_BODY=月末です"
  
  # 通知先アドレスリストを設定から読み込み
  recipients = config['email']['recipients'].join(',')
  puts "EMAIL_TO=#{recipients}"
  
  # ログ出力
  log_entry = {
    date: today.to_s,
    action: "notification_sent",
    timestamp: Time.now.to_s,
    recipients: config['email']['recipients']
  }
  
  # JSONログファイルに追記
  log_file_path = "logs/notification_log.json"
  
  # ログファイルが存在するか確認し、存在しない場合は新規作成
  unless File.exist?(log_file_path)
    File.open(log_file_path, 'w') do |file|
      file.puts(JSON.generate([]))
    end
  end
  
  # 既存のログを読み込み、新しいエントリを追加
  logs = []
  begin
    logs = JSON.parse(File.read(log_file_path))
  rescue JSON::ParserError
    # JSONパースエラーの場合は空の配列で初期化
    logs = []
  end
  
  logs << log_entry
  
  # 更新したログを書き込み
  File.open(log_file_path, 'w') do |file|
    file.puts(JSON.pretty_generate(logs))
  end
  
  puts "通知を送信しました: #{today}"
else
  puts "IS_LAST_BUSINESS_DAY=false"
  puts "今日は最終営業日ではありません: #{today}"
end