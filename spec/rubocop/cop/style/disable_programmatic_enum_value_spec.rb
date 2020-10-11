# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DisableProgrammaticEnumValue do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  # TODO: Write test code
  #
  # For example
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      ruby_enum.each_value { |type| enum_value type }
      ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      enum_value type1
      enum_value type2
    RUBY
  end
end
