#!/usr/bin/env ruby

require 'date'
require_relative '../lib/business_day_calculator'

# 月末判定専用スクリプト
class MonthEndDeterminer
  def initialize
    @business_day_calculator = BusinessDayCalculator.new
  end

  def run
    # 環境変数から日付を取得（指定がなければ今日の日付を使用）
    date_str = ENV['INPUT_DATE']
    date = if date_str && !date_str.empty?
      begin
        Date.parse(date_str)
      rescue ArgumentError
        puts "Error: Invalid date format '#{date_str}'. Using today's date instead."
        Date.today
      end
    else
      Date.today
    end

    # 月末判定を実行
    is_last_business_day = @business_day_calculator.last_business_day_of_current_month?(date)
    formatted_date = "#{date.year}年#{date.month}月#{date.day}日"

    # GitHub Actionsの出力を設定
    ENV['GITHUB_OUTPUT'].tap do |env_file|
      if env_file.nil?
        puts "is_last_business_day=#{is_last_business_day}"
        puts "executed_at=#{formatted_date}"
      else
        File.open(env_file, 'a') do |file|
          file.puts "is_last_business_day=#{is_last_business_day}"
          file.puts "executed_at=\"#{formatted_date}\""
        end
      end
    end
  end
end

# スクリプトを実行
MonthEndDeterminer.new.run
