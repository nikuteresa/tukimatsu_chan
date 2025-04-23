require 'yaml'
require 'fileutils'

# 設定ファイルの読み込み・管理を行うクラス
class ConfigManager
  DEFAULT_CONFIG = {
    'email' => {
      'recipients' => ['default@example.com'],
      'default_time' => '18:00'
    }
  }.freeze

  # 設定ファイルのパス
  CONFIG_PATH = 'config/settings.yml'.freeze

  # 設定の読み込み
  def load
    create_config_if_not_exists
    YAML.load_file(CONFIG_PATH)
  end

  # 設定ファイルが存在しない場合はデフォルト設定で作成
  def create_config_if_not_exists
    return if File.exist?(CONFIG_PATH)
    
    FileUtils.mkdir_p(File.dirname(CONFIG_PATH)) unless Dir.exist?(File.dirname(CONFIG_PATH))
    File.open(CONFIG_PATH, 'w') do |file|
      file.write(DEFAULT_CONFIG.to_yaml)
    end
  end

  # 複数の受信者をカンマ区切りの文字列に変換
  def recipients_to_string(config)
    config.dig('email', 'recipients').join(',')
  end

  # 通知時間の取得
  def notification_time(config)
    config.dig('email', 'default_time')
  end
end