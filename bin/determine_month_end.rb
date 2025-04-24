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
    set_environment_variables(is_last_business_day, date)

  end

  private

  def set_environment_variables(is_last_business_day, date)
    puts "IS_LAST_BUSINESS_DAY=#{is_last_business_day}"
    puts "YEAR_MONTH_DAY=#{date}"
  end
end

# スクリプトを実行
MonthEndDeterminer.new.run
