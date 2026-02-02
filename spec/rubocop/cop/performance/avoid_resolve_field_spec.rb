# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::AvoidResolveField, :config do
  it 'registers an offense when using resolve_field' do
    expect_offense(<<~RUBY)
      resolve_field(field: 'full_name', object: user, args: args, context: context)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `resolve_field` skips the GraphQL layer. Use `resolve_raw_query` instead to replicate real client behavior.
    RUBY
  end

  it 'does not register an offense when using resolve_raw_query' do
    expect_no_offenses(<<~RUBY)
      resolve_raw_query(query, user: user, variables: { id: user.gid })
    RUBY
  end
end
