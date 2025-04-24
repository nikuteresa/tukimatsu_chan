#!/usr/bin/env ruby

require 'time'
require_relative '../lib/business_day_calculator'

# 月末判定専用スクリプト
class MonthEndDeterminer
  def initialize
    @business_day_calculator = BusinessDayCalculator.new
  end

  def run
    ENV['TZ'] = 'Asia/Tokyo' # タイムゾーンを東京に設定
    date = Time.now.to_date

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
