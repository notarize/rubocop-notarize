# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RequireConstantPrefix, :config do
  it 'registers offenses for custom constants without :: prefix' do
    expect_offense(<<~RUBY)
      MyClass.new
      ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      SomeModule.method
      ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      CONSTANT_VALUE
      ^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      CustomError.new
      ^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
    RUBY

    expect_correction(<<~RUBY)
      ::MyClass.new
      ::SomeModule.method
      ::CONSTANT_VALUE
      ::CustomError.new
    RUBY
  end

  it 'intelligently resolves constants to full namespace when definition found' do
    expect_offense(<<~RUBY)
      module MyNamespace
        class MyClass
        end
        
        def test_method
          MyClass.new
          ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module MyNamespace
        class MyClass
        end
        
        def test_method
          ::MyNamespace::MyClass.new
        end
      end
    RUBY
  end

  it 'resolves nested namespace constants correctly' do
    expect_offense(<<~RUBY)
      module Outer
        module Inner
          class TargetClass
          end
          
          def test_method
            TargetClass.new
            ^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module Outer
        module Inner
          class TargetClass
          end
          
          def test_method
            ::Outer::Inner::TargetClass.new
          end
        end
      end
    RUBY
  end

  it 'resolves constants defined with assignment' do
    expect_offense(<<~RUBY)
      module MyModule
        CONSTANT_VALUE = 42
        
        def use_constant
          puts CONSTANT_VALUE
               ^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module MyModule
        CONSTANT_VALUE = 42
        
        def use_constant
          puts ::MyModule::CONSTANT_VALUE
        end
      end
    RUBY
  end

  it 'falls back to simple :: prefix when constant not found in current file' do
    expect_offense(<<~RUBY)
      module MyModule
        def test_method
          UnknownClass.new
          ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
          UNKNOWN_CONSTANT
          ^^^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module MyModule
        def test_method
          ::UnknownClass.new
          ::UNKNOWN_CONSTANT
        end
      end
    RUBY
  end

  it 'handles constants defined in parent namespaces' do
    expect_offense(<<~RUBY)
      module Parent
        PARENT_CONSTANT = "value"
        
        module Child
          def test_method
            PARENT_CONSTANT
            ^^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module Parent
        PARENT_CONSTANT = "value"
        
        module Child
          def test_method
            ::Parent::PARENT_CONSTANT
          end
        end
      end
    RUBY
  end

  it 'resolves constants across different definition styles' do
    expect_offense(<<~RUBY)
      class MyClass
      end
      
      module MyModule
        CONSTANT = 42
      end
      
      def global_method
        MyClass.new
        ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        MyModule::CONSTANT
        ^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyClass
      end
      
      module MyModule
        CONSTANT = 42
      end
      
      def global_method
        ::MyClass.new
        ::MyModule::CONSTANT
      end
    RUBY
  end

  it 'registers offenses for nested constants without :: prefix on root' do
    expect_offense(<<~RUBY)
      MyClass::CONSTANT
      ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      SomeModule::NestedClass.new
      ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      CustomNamespace::Error
      ^^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
    RUBY

    expect_correction(<<~RUBY)
      ::MyClass::CONSTANT
      ::SomeModule::NestedClass.new
      ::CustomNamespace::Error
    RUBY
  end

  it 'does not register offenses for Ruby stdlib constants without :: prefix' do
    expect_no_offenses(<<~RUBY)
      String.new
      Array.new
      Hash.new
      File.read('test.txt')
      Time.now
      JSON.parse('{}')
      Pathname.new('/tmp')
      URI.parse('http://example.com')
      CSV.parse('a,b,c')
      YAML.load('key: value')
      Date.today
      DateTime.now
      BigDecimal('10.5')
      StringIO.new
      Tempfile.new
      Logger.new(STDOUT)
      Set.new([1, 2, 3])
      OpenStruct.new
      Random.new
      SecureRandom.hex
    RUBY
  end

  it 'does not register offenses for constants with :: prefix' do
    expect_no_offenses(<<~RUBY)
      ::String.new
      ::Array.new
      ::Hash.new
      ::File.read('test.txt')
      ::MyClass.new
      ::SomeModule.method
      ::CONSTANT_VALUE
      ::MyClass::CONSTANT
      ::SomeModule::NestedClass.new
    RUBY
  end

  it 'handles mixed stdlib and custom constants correctly' do
    expect_offense(<<~RUBY)
      result = String.new + MyClass.new
                            ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      Hash.new.merge(CustomHash.new)
                     ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      Array.new << CustomArray.new
                   ^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
    RUBY

    expect_correction(<<~RUBY)
      result = String.new + ::MyClass.new
      Hash.new.merge(::CustomHash.new)
      Array.new << ::CustomArray.new
    RUBY
  end

  it 'handles constants in class and module definitions' do
    expect_offense(<<~RUBY)
      class MyClass < CustomBase
                      ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        include CustomModule
                ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        
        def initialize
          @value = Hash.new
          @custom = CustomHash.new
                    ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class MyClass < ::CustomBase
        include ::CustomModule
        
        def initialize
          @value = Hash.new
          @custom = ::CustomHash.new
        end
      end
    RUBY
  end

  it 'handles complex namespace resolution scenarios' do
    expect_offense(<<~RUBY)
      module A
        class B
        end
        
        module C
          class B
          end
          
          def test_method
            B.new
            ^ Use `::` prefix for constants to ensure resolution from root namespace.
          end
        end
        
        def another_method
          B.new
          ^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module A
        class B
        end
        
        module C
          class B
          end
          
          def test_method
            ::A::C::B.new
          end
        end
        
        def another_method
          ::A::B.new
        end
      end
    RUBY
  end

  it 'handles edge cases with stdlib constants' do
    expect_no_offenses(<<~RUBY)
      # Core classes
      Object.new
      Class.new
      Module.new
      Kernel.puts('test')
      
      # Numeric types
      Integer(42)
      Float(3.14)
      Rational(1, 2)
      Complex(1, 2)
      
      # Collections
      Enumerable
      Comparable
      
      # I/O and filesystem
      IO.new(0)
      Dir.pwd
      
      # Other stdlib
      Process.pid
      Thread.current
      Fiber.new {}
      Marshal.dump({})
      ObjectSpace.count_objects
    RUBY
  end
end
