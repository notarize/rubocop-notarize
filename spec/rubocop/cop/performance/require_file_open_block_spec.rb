# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::RequireFileOpenBlock do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using .open with a String parameter' do
    expect_offense(<<~RUBY)
      File.open("file_path")
      ^^^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when using .open with a parameter' do
    expect_offense(<<~RUBY)
      File.open(file_path)
      ^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when using .open with 2 parameters' do
    expect_offense(<<~RUBY)
      f = File.open("file_path", 'w')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when assigning .open to a variable' do
    expect_offense(<<~RUBY)
      file = File.open(file_path)
             ^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when using .open with .tap' do
    expect_offense(<<~RUBY)
      File.open(file_path).tap do |file|
      ^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
        file.read
      end
    RUBY
  end

  it 'registers an offense when yielding .open without a block' do
    expect_offense(<<~RUBY)
      yield(@image.tempfile.open).tap { @image.tempfile.close }
            ^^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when using .open in an inline condition' do
    expect_offense(<<~RUBY)
      tempfile.open if tempfile.closed? && !opts[:unlink]
      ^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'registers an offense when using .open in an hash' do
    expect_offense(<<~RUBY)
      remote_png_asset = RemoteFileStorage.assets.upload_file(
        file: png.tempfile.open,
              ^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
        key: png_key,
        options: { content_type: png.mime_type }
      )
    RUBY
  end

  it 'registers an offense when chaining .open with another call' do
    expect_offense(<<~RUBY)
      Base64.strict_encode64(image.tempfile.open.read)
                             ^^^^^^^^^^^^^^^^^^^ Use File.open with a block to ensure the file is closed after use.
    RUBY
  end

  it 'does not register an offense when using .open with an inline block' do
    expect_no_offenses(<<~RUBY)
      File.open(file_path) { |file| file.read }
    RUBY
  end

  it 'does not register an offense when assigning .open with an inline block' do
    expect_no_offenses(<<~RUBY)
      xml_file = remote_file.open { |contents| Nokogiri::XML(contents) }
    RUBY
  end

  it 'does not register an offense when using .open with a multiline block' do
    expect_no_offenses(<<~RUBY)
      File.open("jeremie") do |file|
        file.read
      end
    RUBY
  end

  it 'does not register an offense when using .open with 2 parameters and an inline block' do
    expect_no_offenses(<<~RUBY)
      File.open(@image.path, 'rb') do |file|
        Base64.strict_encode64(file.read)
      end
    RUBY
  end
end

