#!/usr/bin/env ruby

require 'date'
require_relative '../lib/config_manager'
require_relative '../lib/logger'
require_relative '../lib/notifier'

# 通知専用スクリプト
class NotificationSender
  def initialize
    @config_manager = ConfigManager.new
    @logger = Logger.new
  end

  def run(date = Date.today, force_send = false)
    config = @config_manager.load
    
    # force_send = true の場合、または環境変数が 'true' の場合に通知を送信
    is_last_business_day = force_send || (ENV['IS_LAST_BUSINESS_DAY'] == 'true')
    
    if is_last_business_day
      send_notification(date, config)
    else
      puts "通知は送信されません。今日は最終営業日ではありません: #{date}"
    end
  end
  
  private
  
  def send_notification(date, config)
    notifier = Notifier.new(date, config)
    
    # 環境変数用の出力を生成
    puts notifier.generate_env_output
    
    # ログに記録
    @logger.log_notification(date, config.dig('email', 'recipients'))
    
    puts "通知を送信しました: #{date}"
  end
end

# コマンドライン引数を解析
force_send = ARGV.include?('--force')

# スクリプトを実行
NotificationSender.new.run(Date.today, force_send)
