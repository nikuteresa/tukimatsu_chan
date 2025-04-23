require 'json'
require 'fileutils'

# ログの記録・管理を行うクラス
class Logger
  # ログファイルのパス
  LOG_PATH = 'logs/notification_log.json'.freeze

  # ログを記録する
  def log_notification(date, recipients)
    create_log_directory
    create_log_file_if_not_exists
    
    log_entry = {
      date: date.to_s,
      action: 'notification_sent',
      timestamp: Time.now.to_s,
      recipients: recipients
    }
    
    # 既存のログを読み込む
    logs = read_logs
    
    # 新しいログを追加
    logs << log_entry
    
    # ログを書き込む
    write_logs(logs)
  end

  private

  # ログディレクトリを作成
  def create_log_directory
    FileUtils.mkdir_p(File.dirname(LOG_PATH)) unless Dir.exist?(File.dirname(LOG_PATH))
  end

  # ログファイルが存在しない場合は作成
  def create_log_file_if_not_exists
    return if File.exist?(LOG_PATH)
    
    write_logs([])
  end

  # ログを読み込む
  def read_logs
    begin
      JSON.parse(File.read(LOG_PATH))
    rescue JSON::ParserError, Errno::ENOENT
      []
    end
  end

  # ログを書き込む
  def write_logs(logs)
    File.open(LOG_PATH, 'w') do |file|
      file.puts(JSON.pretty_generate(logs))
    end
  end
end