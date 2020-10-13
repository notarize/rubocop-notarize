# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Do not assign GraphQL Enums programmatically.
      # Doing so obfuscates changes to clients that break when new Enums are added.
      #
      # @example DisableProgrammaticEnumValue:
      #
      #   # bad
      #   RubyEnum.each_value { |type| enum_value type }
      #
      #   # good
      #   enum_value RubyEnum::TYPE
      class DisableProgrammaticEnumValue < Base
        MSG = 'Do not assign graphql enums programmatically.'

        def_node_matcher :each_value?, <<~PATTERN
            (send (...) :each_value)
        PATTERN

        def on_block(node)
          return unless each_value?(node.send_node)
          return unless [:enum_value, :value].include?(node.body.method_name)

          add_offense(node)
        end

      end
    end
  end
end
