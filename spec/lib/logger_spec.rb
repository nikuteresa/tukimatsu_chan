require 'spec_helper'
require_relative '../../lib/logger'

RSpec.describe Logger do
  let(:logger) { described_class.new }
  let(:log_path) { Logger::LOG_PATH }
  let(:test_date) { Date.new(2025, 4, 23) }
  let(:test_recipients) { ['test1@example.com', 'test2@example.com'] }
  
  before do
    # テスト前にログディレクトリとファイルをクリア
    remove_temp_directory(File.dirname(log_path))
  end
  
  after do
    # テスト後にディレクトリをクリーンアップ
    remove_temp_directory(File.dirname(log_path))
  end
  
  describe '#log_notification' do
    context 'ログファイルが存在しない場合' do
      it 'ログディレクトリとファイルを作成してログを記録する' do
        expect(File.exist?(log_path)).to be false
        
        Timecop.freeze(Time.local(2025, 4, 23, 15, 30, 0)) do
          logger.log_notification(test_date, test_recipients)
        end
        
        # ログファイルが作成されていることを確認
        expect(File.exist?(log_path)).to be true
        
        # 記録された内容を確認
        logs = JSON.parse(File.read(log_path))
        expect(logs.size).to eq 1
        expect(logs[0]['date']).to eq '2025-04-23'
        expect(logs[0]['action']).to eq 'notification_sent'
        expect(logs[0]['timestamp']).to eq '2025-04-23 15:30:00 +0900'
        expect(logs[0]['recipients']).to eq test_recipients
      end
    end
    
    context 'ログファイルが既に存在する場合' do
      before do
        # ログファイルを事前に作成
        create_temp_directory(File.dirname(log_path))
        existing_logs = [
          {
            date: '2025-04-22',
            action: 'notification_sent',
            timestamp: '2025-04-22 15:30:00 +0900',
            recipients: ['old@example.com']
          }
        ]
        File.open(log_path, 'w') { |f| f.puts(JSON.pretty_generate(existing_logs)) }
      end
      
      it '既存のログに新しいログを追加する' do
        Timecop.freeze(Time.local(2025, 4, 23, 15, 30, 0)) do
          logger.log_notification(test_date, test_recipients)
        end
        
        # 記録された内容を確認
        logs = JSON.parse(File.read(log_path))
        expect(logs.size).to eq 2
        
        # 古いログがそのまま残っていることを確認
        expect(logs[0]['date']).to eq '2025-04-22'
        expect(logs[0]['recipients']).to eq ['old@example.com']
        
        # 新しいログが追加されていることを確認
        expect(logs[1]['date']).to eq '2025-04-23'
        expect(logs[1]['recipients']).to eq test_recipients
      end
    end
    
    context 'ログファイルの内容が不正な場合' do
      before do
        # 不正なJSON形式のログファイルを作成
        create_temp_directory(File.dirname(log_path))
        File.open(log_path, 'w') { |f| f.puts('This is not a valid JSON') }
      end
      
      it 'ファイルをリセットして新しいログを記録する' do
        Timecop.freeze(Time.local(2025, 4, 23, 15, 30, 0)) do
          logger.log_notification(test_date, test_recipients)
        end
        
        # 記録された内容を確認
        logs = JSON.parse(File.read(log_path))
        expect(logs.size).to eq 1
        expect(logs[0]['date']).to eq '2025-04-23'
        expect(logs[0]['recipients']).to eq test_recipients
      end
    end
  end
  
  # privateメソッドのテスト
  describe 'private methods' do
    describe '#create_log_directory' do
      it 'ログディレクトリが存在しない場合は作成する' do
        expect(Dir.exist?(File.dirname(log_path))).to be false
        
        logger.send(:create_log_directory)
        
        expect(Dir.exist?(File.dirname(log_path))).to be true
      end
    end
    
    describe '#create_log_file_if_not_exists' do
      before do
        # ログディレクトリを作成
        create_temp_directory(File.dirname(log_path))
      end
      
      it 'ログファイルが存在しない場合は空の配列で初期化する' do
        expect(File.exist?(log_path)).to be false
        
        logger.send(:create_log_file_if_not_exists)
        
        expect(File.exist?(log_path)).to be true
        expect(JSON.parse(File.read(log_path))).to eq []
      end
    end
    
    describe '#read_logs' do
      context 'ログファイルが存在する場合' do
        before do
          create_temp_directory(File.dirname(log_path))
          test_logs = [{ date: '2025-04-22', action: 'test' }]
          File.open(log_path, 'w') { |f| f.puts(JSON.pretty_generate(test_logs)) }
        end
        
        it 'ログファイルの内容を返す' do
          logs = logger.send(:read_logs)
          expect(logs.size).to eq 1
          expect(logs[0]['date']).to eq '2025-04-22'
        end
      end
      
      context 'ログファイルが存在しない場合' do
        it '空の配列を返す' do
          logs = logger.send(:read_logs)
          expect(logs).to eq []
        end
      end
      
      context 'ログファイルが不正なJSON形式の場合' do
        before do
          create_temp_directory(File.dirname(log_path))
          File.open(log_path, 'w') { |f| f.puts('Invalid JSON') }
        end
        
        it '空の配列を返す' do
          logs = logger.send(:read_logs)
          expect(logs).to eq []
        end
      end
    end
    
    describe '#write_logs' do
      before do
        create_temp_directory(File.dirname(log_path))
      end
      
      it 'ログをJSON形式でファイルに書き込む' do
        test_logs = [{ date: '2025-04-23', action: 'test' }]
        
        logger.send(:write_logs, test_logs)
        
        logs = JSON.parse(File.read(log_path))
        expect(logs.size).to eq 1
        expect(logs[0]['date']).to eq '2025-04-23'
        expect(logs[0]['action']).to eq 'test'
      end
    end
  end
end