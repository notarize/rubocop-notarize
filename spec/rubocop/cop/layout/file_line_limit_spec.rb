# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FileLineLimit do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when file exceeds the maximum line limit' do
    file_content = <<~RUBY
      #{'puts "Hello, world!"' * 1181}
    RUBY

    expect_offense(file_content, message: 'This file contains more than 100 lines of code.')
  end

  it 'does not register an offense when file is within the line limit' do
    file_content = <<~RUBY
      #{'puts "Hello, world!"' * 1180}
    RUBY

    expect_no_offenses(file_content)
  end
end
