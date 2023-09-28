# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::DisableReload, :config do
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      object.reload
      ^^^^^^^^^^^^^ Update the model in memory instead of calling .reload
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      good_method
    RUBY
  end
end
