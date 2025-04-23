require 'spec_helper'
require_relative '../../lib/application'

RSpec.describe Application do
  let(:application) { described_class.new }
  let(:config_manager) { instance_double('ConfigManager') }
  let(:business_day_calculator) { instance_double('BusinessDayCalculator') }
  let(:logger) { instance_double('Logger') }
  let(:notifier) { instance_double('Notifier') }
  let(:date) { Date.new(2025, 4, 23) }
  let(:config) do
    {
      'email' => {
        'recipients' => ['test@example.com'],
        'default_time' => '18:00'
      }
    }
  end
  
  before do
    # 依存クラスをモック化
    allow(ConfigManager).to receive(:new).and_return(config_manager)
    allow(BusinessDayCalculator).to receive(:new).and_return(business_day_calculator)
    allow(Logger).to receive(:new).and_return(logger)
    allow(Notifier).to receive(:new).and_return(notifier)
  end
  
  describe '#initialize' do
    it '依存クラスを初期化する' do
      # 依存クラスのインスタンスが作成されることを確認
      expect(ConfigManager).to receive(:new)
      expect(BusinessDayCalculator).to receive(:new)
      expect(Logger).to receive(:new)
      
      described_class.new
    end
  end
  
  describe '#run' do
    before do
      allow(config_manager).to receive(:load).and_return(config)
    end
    
    context '最終営業日の場合' do
      before do
        allow(business_day_calculator).to receive(:last_business_day_of_current_month?)
          .with(date).and_return(true)
        allow(notifier).to receive(:generate_env_output).and_return('ENV_OUTPUT')
        allow(logger).to receive(:log_notification)
        allow(Notifier).to receive(:new).with(date, config).and_return(notifier)
      end
      
      it '通知処理を実行する' do
        # 通知処理が実行されることを確認
        expect(Notifier).to receive(:new).with(date, config)
        expect(notifier).to receive(:generate_env_output)
        expect(logger).to receive(:log_notification).with(date, ['test@example.com'])
        
        # 標準出力をキャプチャし、期待される出力があることを確認
        expect {
          application.run(date)
        }.to output(/IS_LAST_BUSINESS_DAY=true/).to_stdout
      end
    end
    
    context '最終営業日でない場合' do
      before do
        allow(business_day_calculator).to receive(:last_business_day_of_current_month?)
          .with(date).and_return(false)
      end
      
      it '通常の処理を実行し、通知を送信しない' do
        # 通知処理が実行されないことを確認
        expect(Notifier).not_to receive(:new)
        expect(logger).not_to receive(:log_notification)
        
        # 標準出力をキャプチャし、期待される出力があることを確認
        expect {
          application.run(date)
        }.to output(/IS_LAST_BUSINESS_DAY=false/).to_stdout
      end
    end
  end
  
  describe 'private methods' do
    describe '#handle_last_business_day' do
      before do
        allow(Notifier).to receive(:new).with(date, config).and_return(notifier)
        allow(notifier).to receive(:generate_env_output).and_return('ENV_OUTPUT')
        allow(logger).to receive(:log_notification)
      end
      
      it '通知処理を実行する' do
        expect(Notifier).to receive(:new).with(date, config)
        expect(notifier).to receive(:generate_env_output)
        expect(logger).to receive(:log_notification).with(date, ['test@example.com'])
        
        expect {
          application.send(:handle_last_business_day, date, config)
        }.to output(/通知を送信しました/).to_stdout
      end
    end
    
    describe '#handle_regular_day' do
      it '通常日の処理を実行する' do
        expect {
          application.send(:handle_regular_day, date)
        }.to output(/IS_LAST_BUSINESS_DAY=false/).to_stdout
      end
    end
  end
end