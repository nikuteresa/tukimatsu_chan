require 'simplecov'
if ENV['COVERAGE']
  SimpleCov.start do
    add_filter "/spec/"
  end
  puts "Running with SimpleCov..."
end

require 'timecop'
require 'webmock/rspec'
require 'fileutils'

# ローカル環境のみでWebMockを有効にする
WebMock.disable_net_connect!(allow_localhost: true)

# spec/support ディレクトリ内のファイルを読み込む
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  # 期待値の記述スタイルをexpect に設定
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # モックのフレームワークを設定
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # 共有コンテキストの説明を繰り返さない
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # テストを実行する前にrandom seedを表示
  config.before(:suite) do
    puts "\n\nUsing RSpec seed: #{config.seed}\n\n"
  end

  # 各テスト実行後、モックと変更を初期化
  config.after(:each) do
    # Timecopをリセット
    Timecop.return
  end

  # 実行順序をランダムにする
  config.order = :random
  Kernel.srand config.seed
end
