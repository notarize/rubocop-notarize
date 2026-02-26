# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Sidekiq::RequireSidekiqTestingInlineBlock, :config do
  it 'registers an offense when using Sidekiq::Testing.inline! without a block' do
    expect_offense(<<~RUBY)
      module Sidekiq; end
      Sidekiq::Testing.inline!
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use Sidekiq::Testing.inline! with a block to ensure setting does not leak
    RUBY
  end

  it 'does not register an offense when using Sidekiq::Testing.inline! with an inline block' do
    expect_no_offenses(<<~RUBY)
      module Sidekiq; end
      Sidekiq::Testing.inline! { 4 * 5 }
    RUBY
  end

  it 'does not register an offense when using Sidekiq::Testing.inline! with a multiline block' do
    expect_no_offenses(<<~RUBY)
      module Sidekiq; end
      Sidekiq::Testing.inline! do
        testing_things
      end
    RUBY
  end
end
