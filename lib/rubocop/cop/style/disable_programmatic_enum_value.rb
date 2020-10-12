# frozen_string_literal: true
require 'pry'

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Style
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
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
