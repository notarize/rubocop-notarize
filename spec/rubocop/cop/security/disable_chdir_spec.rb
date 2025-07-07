# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::DisableChdir, :config do
  it 'registers an offense when using Dir.chdir with a block' do
    expect_offense(<<~RUBY)
      Dir.chdir(APP_ROOT) do
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid using Dir.chdir due to thread safety issues
        123
      end
    RUBY
  end

  it 'registers an offense when using chdir with a block' do
    expect_offense(<<~RUBY)
      chdir APP_ROOT do
      ^^^^^^^^^^^^^^^^^ Avoid using Dir.chdir due to thread safety issues
        123
      end
    RUBY
  end

  it 'does not register an offense when using chdir without a block' do
    expect_no_offenses(<<~RUBY)
      Test.chdir = 123
    RUBY
  end
end
