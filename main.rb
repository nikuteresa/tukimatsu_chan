#!/usr/bin/env ruby

# 両方のスクリプトを実行するためのメインエントリーポイント
# GitHub Actionsでは個別に実行されるため、このファイルは開発環境またはテスト用

require_relative 'bin/determine_month_end'
require_relative 'bin/send_notification'

puts "月末くん: 月末判定と通知処理を完了しました"
