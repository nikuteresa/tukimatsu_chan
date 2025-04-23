module FileHelpers
  # テスト用の一時ディレクトリを作成
  def create_temp_directory(path)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
  end

  # テスト用のファイルを作成
  def create_temp_file(path, content)
    FileUtils.mkdir_p(File.dirname(path)) unless Dir.exist?(File.dirname(path))
    File.open(path, 'w') { |f| f.write(content) }
  end

  # テスト用のファイルを削除
  def remove_temp_file(path)
    File.delete(path) if File.exist?(path)
  end

  # テスト用のディレクトリを削除
  def remove_temp_directory(path)
    FileUtils.rm_rf(path) if Dir.exist?(path)
  end
end

RSpec.configure do |config|
  config.include FileHelpers
end