# frozen_string_literal: true
require 'pry'

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
          return unless invalid_children?(node.body)

          add_offense(node)
        end

        private

        def invalid_children?(node)
          if node.send_type?
            [:enum_value, :value].include?(node.method_name)
          else
            node.children.any? { |child| invalid_children?(child) }
          end
        end
      end
    end
  end
end
