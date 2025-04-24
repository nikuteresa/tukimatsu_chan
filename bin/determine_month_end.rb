#!/usr/bin/env ruby

require 'date'
require_relative '../lib/business_day_calculator'

# 月末判定専用スクリプト
class MonthEndDeterminer
  def initialize
    @business_day_calculator = BusinessDayCalculator.new
  end

  def run(date = Date.today)
    is_last_business_day = @business_day_calculator.last_business_day_of_current_month?(date)
    date = "#{date.year}年#{date.month}月#{date.day}日"

    # 環境変数を設定
    ENV['IS_GETSUMATSU_CHAN'] = is_last_business_day.to_s
    ENV['EXECUTION_DATE_GETSUMATSU_CHAN'] = date
  end
end

# スクリプトを実行
MonthEndDeterminer.new.run
