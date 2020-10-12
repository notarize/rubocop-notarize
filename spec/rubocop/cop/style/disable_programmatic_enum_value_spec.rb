# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DisableProgrammaticEnumValue do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using enumerating to set enum_value' do
    expect_offense(<<~RUBY)
      def method
        ruby_enum.each_value { |type| enum_value type }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign graphql enums programmatically.
      end
    RUBY
  end

  it 'registers an offense when using enumerating to set enum_value' do
    expect_offense(<<~RUBY)
      def method
        ruby_enum.each_value { |type| value type }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign graphql enums programmatically.
      end
    RUBY
  end

  it 'does not register an offense when setting enum_value normally' do
    expect_no_offenses(<<~RUBY)
      enum_value type1
      enum_value type2
    RUBY
  end

  it 'does not register an offense when enumerating lists' do
    expect_no_offenses(<<~RUBY)
      ruby_enum.each_value { |type| puts type }
    RUBY
  end
end