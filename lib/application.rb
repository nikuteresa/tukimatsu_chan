require_relative 'business_day_calculator'
require_relative 'config_manager'
require_relative 'logger'
require_relative 'notifier'

# アプリケーション全体を制御するクラス
class Application
  def initialize
    @config_manager = ConfigManager.new
    @business_day_calculator = BusinessDayCalculator.new
    @logger = Logger.new
  end

  # アプリケーションを実行
  def run(date = Date.today)
    config = @config_manager.load
    
    if @business_day_calculator.last_business_day_of_current_month?(date)
      handle_last_business_day(date, config)
    else
      handle_regular_day(date)
    end
  end

  private

  # 最終営業日の処理
  def handle_last_business_day(date, config)
    notifier = Notifier.new(date, config)
    
    # 環境変数用の出力を生成
    puts notifier.generate_env_output
    
    # ログに記録
    @logger.log_notification(date, config.dig('email', 'recipients'))
    
    puts "通知を送信しました: #{date}"
  end

  # 通常日の処理
  def handle_regular_day(date)
    puts "IS_LAST_BUSINESS_DAY=false"
    puts "今日は最終営業日ではありません: #{date}"
  end
end