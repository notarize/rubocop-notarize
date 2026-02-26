# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::DisableInspect, :config do
  it 'registers an offense when using .inspect and autocorrects' do
    expect_offense(<<~RUBY)
      object.inspect
      ^^^^^^^^^^^^^^ Avoid using .inspect as it can leak sensitive data into logs
    RUBY

    expect_correction(<<~RUBY)
      object
    RUBY
  end

  it 'does not register an offense when using .to_s' do
    expect_no_offenses(<<~RUBY)
      object.to_s
    RUBY
  end
end
