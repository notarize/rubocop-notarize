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
            ::A::B.new
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

  it 'does not register offenses for constants in class and module definitions' do
    expect_no_offenses(<<~RUBY)
      class MyClass
        def method
          puts "inside MyClass"
        end
      end

      module MyModule
        def self.method
          puts "inside MyModule"
        end
      end

      class Parent::Child
        def method
          puts "inside Parent::Child"
        end
      end

      module Outer::Inner::Deep
        def self.method
          puts "inside Outer::Inner::Deep"
        end
      end
    RUBY
  end

  it 'registers offenses for nested constants in non-definition contexts' do
    expect_offense(<<~RUBY)
      def some_method
        MyClass::CONSTANT
        ^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        Parent::Child.new
        ^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        Outer::Inner::Deep.method
        ^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      end
    RUBY

    expect_correction(<<~RUBY)
      def some_method
        ::MyClass::CONSTANT
        ::Parent::Child.new
        ::Outer::Inner::Deep.method
      end
    RUBY
  end

  it 'handles mixed class definitions and constant references correctly' do
    expect_offense(<<~RUBY)
      class Parent::Child
        def method
          Other::CONSTANT
          ^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        end
      end

      def global_method
        Parent::Child.new
        ^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Parent::Child
        def method
          ::Other::CONSTANT
        end
      end

      def global_method
        ::Parent::Child.new
      end
    RUBY
  end

  it 'corrects a nested constant definition as a method argument' do
    expect_offense(<<~RUBY)
      formatter SimpleCov::Formatter::SimpleFormatter
                ^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
    RUBY

    expect_correction(<<~RUBY)
      formatter ::SimpleCov::Formatter::SimpleFormatter
    RUBY
  end

  it 'corrects an entire file' do
    expect_offense(<<~RUBY)
      # typed: true
      # frozen_string_literal: true

      # Used by notaries to receive realtime updates on new meetings &
      # latest meeting events.
      class NotaryChannel < ApplicationCable::Channel
                            ^^^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
        sig { void }
        def subscribed
          authorized_notary = current_user.notary? && current_user.notary_profile&.can_take_meetings?
          authorized_notary ? stream_for(current_user) : reject
        end

        # no-op handler so client can send a ping
        def hi_arturo; end

        sig { params(data: T.anything).void }
        def perform_action(data)
          ::Monitoring::Service.log(::Monitoring::DataPoint::SOCKET_EVENTS::CHANNEL, "notary")
          super
        end

        def acknowledge_call_delivery(data)
          meeting_request_gid, client_receipt_time, panel_membership_gid, reveal_state = data.values_at(
            'meetingRequestGid', 'clientReceiptTime', 'panelMembershipGid', 'revealState'
          )
          meeting_request = MeetingRequest.find_by(id: Graph::Helpers::GlobalIdRegistrar.decode_gid(meeting_request_gid))
                                                       ^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
                            ^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.

          panel_membership = panel_membership_gid.presence ?
                             Panels::API::Service.get_panel_notary_membership(Graph::Helpers::GlobalIdRegistrar.decode_gid(panel_membership_gid)) :
                                                                              ^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
                             ^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
                               nil

          if meeting_request.nil?
            ::MeetingRouting::Logger.log_error("Unexpected meeting request delivery acknowledgement data: " \
                                                 "meeting_request_gid: \#{meeting_request_gid}, " \
                                                 "panel_membership_gid: \#{panel_membership_gid}, " \
                                                 "client_receipt_time: \#{client_receipt_time}")
            return
          end

          Monitoring::Events::Custom.create('MeetingRouting/DeliveryCallAcknowledgement', timing_enabled: false) do |event|
          ^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
            event.log('meeting_request_id', meeting_request.id)
            event.log('meeting_request_gid', meeting_request_gid)
            event.log('document_bundle_id', meeting_request.document_bundle_id)
            event.log('agent_user_id', current_user.id)
            event.log('agent_user_gid', current_user.gid)
            event.log('panel_id', panel_membership&.panel_id)
            event.log('client_receipt_time', client_receipt_time)
            event.log('reveal_state', reveal_state)
          end
        end

        def update_presence(data)
          case status = MeetingAgent::Status.try_deserialize(data["status"])
                        ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
          when MeetingAgent::Status::AVAILABLE, MeetingAgent::Status::UNAVAILABLE
               ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
                                                ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
            meeting = data["meeting_gid"].present? ? SafeFetchGlobalId.meeting(connection.current_user_power, data["meeting_gid"]) : nil
                                                     ^^^^^^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
            MeetingAgent::Presence.heartbeat(agent: current_user, status: status, meeting: meeting, source: "ActionCable")
            ^^^^^^^^^^^^ Use `::` prefix for constants to ensure resolution from root namespace.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      # typed: true
      # frozen_string_literal: true

      # Used by notaries to receive realtime updates on new meetings &
      # latest meeting events.
      class NotaryChannel < ::ApplicationCable::Channel
        sig { void }
        def subscribed
          authorized_notary = current_user.notary? && current_user.notary_profile&.can_take_meetings?
          authorized_notary ? stream_for(current_user) : reject
        end

        # no-op handler so client can send a ping
        def hi_arturo; end

        sig { params(data: T.anything).void }
        def perform_action(data)
          ::Monitoring::Service.log(::Monitoring::DataPoint::SOCKET_EVENTS::CHANNEL, "notary")
          super
        end

        def acknowledge_call_delivery(data)
          meeting_request_gid, client_receipt_time, panel_membership_gid, reveal_state = data.values_at(
            'meetingRequestGid', 'clientReceiptTime', 'panelMembershipGid', 'revealState'
          )
          meeting_request = ::MeetingRequest.find_by(id: ::Graph::Helpers::GlobalIdRegistrar.decode_gid(meeting_request_gid))

          panel_membership = panel_membership_gid.presence ?
                             ::Panels::API::Service.get_panel_notary_membership(::Graph::Helpers::GlobalIdRegistrar.decode_gid(panel_membership_gid)) :
                               nil

          if meeting_request.nil?
            ::MeetingRouting::Logger.log_error("Unexpected meeting request delivery acknowledgement data: " \
                                                 "meeting_request_gid: \#{meeting_request_gid}, " \
                                                 "panel_membership_gid: \#{panel_membership_gid}, " \
                                                 "client_receipt_time: \#{client_receipt_time}")
            return
          end

          ::Monitoring::Events::Custom.create('MeetingRouting/DeliveryCallAcknowledgement', timing_enabled: false) do |event|
            event.log('meeting_request_id', meeting_request.id)
            event.log('meeting_request_gid', meeting_request_gid)
            event.log('document_bundle_id', meeting_request.document_bundle_id)
            event.log('agent_user_id', current_user.id)
            event.log('agent_user_gid', current_user.gid)
            event.log('panel_id', panel_membership&.panel_id)
            event.log('client_receipt_time', client_receipt_time)
            event.log('reveal_state', reveal_state)
          end
        end

        def update_presence(data)
          case status = ::MeetingAgent::Status.try_deserialize(data["status"])
          when ::MeetingAgent::Status::AVAILABLE, ::MeetingAgent::Status::UNAVAILABLE
            meeting = data["meeting_gid"].present? ? ::SafeFetchGlobalId.meeting(connection.current_user_power, data["meeting_gid"]) : nil
            ::MeetingAgent::Presence.heartbeat(agent: current_user, status: status, meeting: meeting, source: "ActionCable")
          end
        end
      end
    RUBY
  end
end
