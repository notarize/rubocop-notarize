# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::RequireFrozenStringLiteral, :config do
  it 'has the comment' do
    expect_no_offenses(<<~RUBY)
      # typed: strict
      # frozen_string_literal: true
      module Thing; end
    RUBY
  end

  it 'has the comment and a string constant' do
    expect_no_offenses(<<~RUBY)
      # typed: strict
      # frozen_string_literal: true
      module Thing
        STRING_CONSTANT = "hello there"
      end
    RUBY
  end

  it 'has the comment and a string present inside a class method' do
    expect_no_offenses(<<~RUBY)
      # typed: strict
      # frozen_string_literal: true
      module Thing
        def self.create_string
          my_string = "this is a string"
        end
      end
    RUBY
  end

  it 'has the comment and a string present inside an instance method' do
    expect_no_offenses(<<~RUBY)
      # typed: strict
      # frozen_string_literal: true
      module Thing
        def create_string
          my_string = "this is a string"
        end
      end
    RUBY
  end

  it 'does not have the comment and a string constant' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        STRING_CONSTANT = "hello there"
      end
    RUBY
  end

  it 'does not have the comment and a string present inside a class method' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        def self.create_string
          my_string = "this is a string"
        end
      end
    RUBY
  end

  it 'does not have the comment and a string present inside an instance method' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        def create_string
          my_string = "this is a string"
        end
      end
    RUBY
  end

  it 'does not have the comment but has a string present, even if frozen' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        STRING_CONSTANT1 = "hello there".freeze
      end
    RUBY
  end

  it 'does not have the comment but has a string present' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        STRING_CONSTANT2 = 'hello there'
      end
    RUBY
  end

  it 'does not have the comment but has a string that is concatenated' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        STRING_CONSTANT3 = "h" + "ello there"
      end
    RUBY
  end

  it 'does not have the comment but has an interpolated string' do
    expect_offense(<<~RUBY)
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        INTEGER_CONSTANT = 123
        STRING_CONSTANT4 = "hello #{INTEGER_CONSTANT}"
      end
    RUBY
  end
end
