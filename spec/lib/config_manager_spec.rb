require 'spec_helper'
require_relative '../../lib/config_manager'

RSpec.describe ConfigManager do
  let(:config_manager) { described_class.new }
  let(:config_path) { ConfigManager::CONFIG_PATH }
  let(:default_config) { ConfigManager::DEFAULT_CONFIG }
  let(:test_config) do
    {
      'email' => {
        'recipients' => ['test1@example.com', 'test2@example.com'],
        'default_time' => '17:00'
      }
    }
  end
  
  before do
    # テスト用の設定ディレクトリをクリア
    remove_temp_directory(File.dirname(config_path))
  end
  
  after do
    # テスト後にディレクトリをクリーンアップ
    remove_temp_directory(File.dirname(config_path))
  end
  
  describe '#load' do
    context '設定ファイルが存在しない場合' do
      it 'デフォルト設定を作成して読み込む' do
        expect(File.exist?(config_path)).to be false
        
        result = config_manager.load
        
        expect(File.exist?(config_path)).to be true
        expect(result).to eq default_config
      end
    end
    
    context '設定ファイルが存在する場合' do
      before do
        create_temp_directory(File.dirname(config_path))
        File.open(config_path, 'w') { |f| f.write(test_config.to_yaml) }
      end
      
      it '既存の設定ファイルを読み込む' do
        result = config_manager.load
        expect(result).to eq test_config
      end
    end
  end
  
  describe '#create_config_if_not_exists' do
    context '設定ファイルが存在しない場合' do
      it 'デフォルト設定でファイルを作成する' do
        expect(File.exist?(config_path)).to be false
        
        config_manager.create_config_if_not_exists
        
        expect(File.exist?(config_path)).to be true
        expect(YAML.load_file(config_path)).to eq default_config
      end
    end
    
    context '設定ファイルが存在する場合' do
      before do
        create_temp_directory(File.dirname(config_path))
        File.open(config_path, 'w') { |f| f.write(test_config.to_yaml) }
      end
      
      it '既存のファイルを上書きしない' do
        original_content = File.read(config_path)
        config_manager.create_config_if_not_exists
        new_content = File.read(config_path)
        
        expect(new_content).to eq original_content
      end
    end
  end
  
  describe '#recipients_to_string' do
    it '受信者リストをカンマ区切りの文字列に変換する' do
      result = config_manager.recipients_to_string(test_config)
      expect(result).to eq 'test1@example.com,test2@example.com'
    end
    
    it '受信者が1人の場合もカンマなしの文字列を返す' do
      single_recipient_config = {
        'email' => {
          'recipients' => ['single@example.com']
        }
      }
      
      result = config_manager.recipients_to_string(single_recipient_config)
      expect(result).to eq 'single@example.com'
    end
  end
  
  describe '#notification_time' do
    it '通知時間を返す' do
      result = config_manager.notification_time(test_config)
      expect(result).to eq '17:00'
    end
    
    it '通知時間が設定されていない場合はnilを返す' do
      config_without_time = {
        'email' => {
          'recipients' => ['test@example.com']
        }
      }
      
      result = config_manager.notification_time(config_without_time)
      expect(result).to be_nil
    end
  end
end