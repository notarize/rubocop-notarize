# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::GraphCamelize, :config do
  it 'registers offenses when using camelize in arguments definitions' do
    expect_offense(<<~RUBY)
      argument :first_name, String, camelize: false, required: true
                                    ^^^^^^^^^^^^^^^ Do not use the camelize option.
      argument :first_name, String, required: true, camelize: true
                                                    ^^^^^^^^^^^^^^ Do not use the camelize option.
      argument :name,
               required: true,
               camelize: false,
               ^^^^^^^^^^^^^^^ Do not use the camelize option.
               description: "a name"
      argument :name,
               required: true,
               description: "a name",
               camelize: true
               ^^^^^^^^^^^^^^ Do not use the camelize option.
    RUBY

    expect_correction(<<~RUBY)
      argument :first_name, String, required: true
      argument :first_name, String, required: true
      argument :name,
               required: true,
               description: "a name"
      argument :name,
               required: true,
               description: "a name"
    RUBY
  end

  it 'registers offenses when using camelize in fields definitions' do
    expect_offense(<<~RUBY)
      field :updated_at, String, null: true, camelize: false
                                             ^^^^^^^^^^^^^^^ Do not use the camelize option.
      field :updated_at, String, camelize: true, null: true
                                 ^^^^^^^^^^^^^^ Do not use the camelize option.
      field :updated_at, String,
            null: true,
            camelize: false
            ^^^^^^^^^^^^^^^ Do not use the camelize option.
      field :updated_at, String,
            camelize: true,
            ^^^^^^^^^^^^^^ Do not use the camelize option.
            null: true
    RUBY

    expect_correction(<<~RUBY)
      field :updated_at, String, null: true
      field :updated_at, String, null: true
      field :updated_at, String,
            null: true
      field :updated_at, String,
            null: true
    RUBY
  end

  it 'registers offenses when using camelize in a complex field definition' do
    expect_offense(<<~RUBY) \
      field :queried_users, Graph::Connections::UserConnection, null: false, camelize: false, extras: [:lookahead] do
                                                                             ^^^^^^^^^^^^^^^ Do not use the camelize option.
        description "Find users by some attributes, admin users only"

        argument :query, String, camelize: false, description: 'Meeting / transaction gid, user email, last name or gid / id', required: false
                                 ^^^^^^^^^^^^^^^ Do not use the camelize option.
        argument :include_single_use, Boolean, description: '', required: false, default_value: false
      end
    RUBY

    expect_correction(<<~RUBY)
      field :queried_users, Graph::Connections::UserConnection, null: false, extras: [:lookahead] do
        description "Find users by some attributes, admin users only"

        argument :query, String, description: 'Meeting / transaction gid, user email, last name or gid / id', required: false
        argument :include_single_use, Boolean, description: '', required: false, default_value: false
      end
    RUBY
  end
end
