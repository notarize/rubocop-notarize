# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PreferTStruct, :config do
  it 'registers an offense when using T::ImmutableStruct' do
    expect_offense(<<~RUBY)
      class User < T::ImmutableStruct
                   ^^^^^^^^^^^^^^^^^^ Prefer `T::Struct` over `T::ImmutableStruct`.
        const :name, String
        const :email, String
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < T::Struct
        const :name, String
        const :email, String
      end
    RUBY
  end

  it 'registers an offense with multiple classes' do
    expect_offense(<<~RUBY)
      class User < T::ImmutableStruct
                   ^^^^^^^^^^^^^^^^^^ Prefer `T::Struct` over `T::ImmutableStruct`.
        const :name, String
      end

      class Address < T::ImmutableStruct
                      ^^^^^^^^^^^^^^^^^^ Prefer `T::Struct` over `T::ImmutableStruct`.
        const :street, String
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < T::Struct
        const :name, String
      end

      class Address < T::Struct
        const :street, String
      end
    RUBY
  end

  it 'does not register an offense when using T::Struct' do
    expect_no_offenses(<<~RUBY)
      class User < T::Struct
        const :name, String
        const :email, String
      end
    RUBY
  end

  it 'does not register an offense when using other T classes' do
    expect_no_offenses(<<~RUBY)
      class MyClass < T::InexactStruct
        const :name, String
      end
    RUBY
  end

  it 'registers an offense in namespaced classes' do
    expect_offense(<<~RUBY)
      module MyModule
        class User < T::ImmutableStruct
                     ^^^^^^^^^^^^^^^^^^ Prefer `T::Struct` over `T::ImmutableStruct`.
          const :name, String
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module MyModule
        class User < T::Struct
          const :name, String
        end
      end
    RUBY
  end

  it 'registers an offense with complex struct definition' do
    expect_offense(<<~RUBY)
      class ComplexStruct < T::ImmutableStruct
                            ^^^^^^^^^^^^^^^^^^ Prefer `T::Struct` over `T::ImmutableStruct`.
        const :id, Integer
        const :name, String
        const :created_at, DateTime
        prop :optional_field, T.nilable(String)
      end
    RUBY

    expect_correction(<<~RUBY)
      class ComplexStruct < T::Struct
        const :id, Integer
        const :name, String
        const :created_at, DateTime
        prop :optional_field, T.nilable(String)
      end
    RUBY
  end
end
