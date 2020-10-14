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

  it 'registers an offense when using enumerating to set value' do
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

  it 'does not register an offense when not settting value' do
    expect_no_offenses(<<~RUBY)
      ruby_enum.each_value { |type| puts type }
    RUBY
  end

  it 'does not register an offense when many children not setting value' do
    expect_no_offenses(<<~RUBY)
      first_iterator.each_value do |type|
        obj.create(attr: value)
        obj.create(attr: value)
      end
    RUBY
  end

  it 'does not register an offense when child is iterator' do
    expect_no_offenses(<<~RUBY)
      first_iterator.each_value do |type|
        second_iterator.each_value do
          obj.create(attr: value)
          obj.create(attr: value)
        end
      end
    RUBY
  end
end
