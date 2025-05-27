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
    expect_offense(<<~'RUBY')
      # typed: strict
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      module Thing
        INTEGER_CONSTANT = 123
        STRING_CONSTANT4 = "hello #{INTEGER_CONSTANT}"
      end
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment under an encoding comment' do
    expect_offense(<<~RUBY)
      # encoding: utf-8
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      VAL = "hello"
    RUBY

    expect_correction(<<~RUBY)
      # encoding: utf-8
      # frozen_string_literal: true
      VAL = "hello"
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment under a Sorbet comment' do
    expect_offense(<<~RUBY)
      # typed: true
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal

      VAL = "hello"
    RUBY

    expect_correction(<<~RUBY)
      # typed: true
      # frozen_string_literal: true

      VAL = "hello"
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment under a shebang comment' do
    expect_offense(<<~RUBY)
      #!/usr/bin/env ruby
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal

      VAL = "hello"
    RUBY

    expect_correction(<<~RUBY)
      #!/usr/bin/env ruby
      # frozen_string_literal: true

      VAL = "hello"
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment before non-magic leading comment lines' do
    expect_offense(<<~RUBY)
      #!/usr/bin/env ruby
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
      # typed: strict
      # encoding: utf-8
      # hey how's it going? 

      VAL = "hello"
    RUBY

    expect_correction(<<~RUBY)
      #!/usr/bin/env ruby
      # typed: strict
      # encoding: utf-8
      # frozen_string_literal: true
      # hey how's it going? 

      VAL = "hello"
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment if there are no leading magic comment lines' do
    expect_offense(<<~RUBY)
      module Module1
      ^ Require "# frozen_string_literal: true" in any file that creates a string literal
        VAL = "hello"
      end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
      module Module1
        VAL = "hello"
      end
    RUBY
  end

  it 'autocorrects by adding a frozen string literal comment if there are no leading magic comment lines but there are leading empty lines' do
    expect_offense(<<~RUBY)

      ^{} Require "# frozen_string_literal: true" in any file that creates a string literal

      module Module1
        VAL = "hello"
      end
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true


      module Module1
        VAL = "hello"
      end
    RUBY
  end
end
