#!/usr/bin/env ruby

require 'date'
require_relative '../lib/business_day_calculator'
require_relative '../lib/config_manager'

# 月末判定専用スクリプト
class MonthEndDeterminer
  def initialize
    @business_day_calculator = BusinessDayCalculator.new
    @config_manager = ConfigManager.new
  end

  def run(date = Date.today)
    config = @config_manager.load
    
    is_last_business_day = @business_day_calculator.last_business_day_of_current_month?(date)
    year_month = "#{date.year}年#{date.month}月"
    
    # 環境変数を設定
    set_environment_variables(is_last_business_day, year_month)
    
    # 結果を返す
    {
      is_last_business_day: is_last_business_day,
      year_month: year_month
    }
  end
  
  private
  
  def set_environment_variables(is_last_business_day, year_month)
    puts "IS_LAST_BUSINESS_DAY=#{is_last_business_day}"
    puts "YEAR_MONTH=#{year_month}"
  end
end

# スクリプトを実行
MonthEndDeterminer.new.run
