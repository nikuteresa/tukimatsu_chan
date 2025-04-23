require 'spec_helper'
require_relative '../../lib/notifier'

RSpec.describe Notifier do
  let(:date) { Date.new(2025, 4, 23) }
  let(:config) do
    {
      'email' => {
        'recipients' => ['test1@example.com', 'test2@example.com'],
        'default_time' => '18:00'
      }
    }
  end
  let(:notifier) { described_class.new(date, config) }
  
  describe '#initialize' do
    it 'dateとconfigを正しく設定する' do
      expect(notifier.date).to eq date
      expect(notifier.config).to eq config
    end
  end
  
  describe '#prepare_notification' do
    it '通知メッセージを正しく準備する' do
      result = notifier.prepare_notification
      
      expect(result).to be_a(Hash)
      expect(result[:is_last_business_day]).to be true
      expect(result[:subject]).to eq '2025年4月の月末のお知らせ'
      expect(result[:body]).to eq '月末です'
      expect(result[:recipients]).to eq ['test1@example.com', 'test2@example.com']
    end
  end
  
  describe '#generate_env_output' do
    it '環境変数用の出力を正しく生成する' do
      expected_output = [
        "IS_LAST_BUSINESS_DAY=true",
        "EMAIL_SUBJECT=2025年4月の月末のお知らせ",
        "EMAIL_BODY=月末です",
        "EMAIL_TO=test1@example.com,test2@example.com"
      ].join("\n")
      
      result = notifier.generate_env_output
      expect(result).to eq expected_output
    end
    
    context '受信者が1人の場合' do
      let(:config) do
        {
          'email' => {
            'recipients' => ['single@example.com'],
            'default_time' => '18:00'
          }
        }
      end
      
      it '環境変数用の出力を正しく生成する' do
        expected_output = [
          "IS_LAST_BUSINESS_DAY=true",
          "EMAIL_SUBJECT=2025年4月の月末のお知らせ",
          "EMAIL_BODY=月末です",
          "EMAIL_TO=single@example.com"
        ].join("\n")
        
        result = notifier.generate_env_output
        expect(result).to eq expected_output
      end
    end
  end
  
  describe 'private methods' do
    describe '#generate_subject' do
      it '日付に基づいた件名を生成する' do
        result = notifier.send(:generate_subject)
        expect(result).to eq '2025年4月の月末のお知らせ'
      end
      
      it '別の日付でも正しい件名を生成する' do
        different_date = Date.new(2025, 12, 31)
        different_notifier = described_class.new(different_date, config)
        
        result = different_notifier.send(:generate_subject)
        expect(result).to eq '2025年12月の月末のお知らせ'
      end
    end
    
    describe '#generate_body' do
      it '「月末です」という本文を生成する' do
        result = notifier.send(:generate_body)
        expect(result).to eq '月末です'
      end
    end
  end
end