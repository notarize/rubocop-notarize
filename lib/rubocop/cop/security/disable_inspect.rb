# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # Disallow calling .inspect as it can leak sensitive data (PII, credentials)
      # into logs and error outputs.
      #
      # @example
      #
      #   # bad
      #   object.inspect
      #
      #   # good
      #   object.to_s
      #
      class DisableInspect < Base
        extend AutoCorrector

        MSG = 'Avoid using .inspect as it can leak sensitive data into logs'

        def_node_matcher :inspect_call?, <<~PATTERN
          (send (...) :inspect)
        PATTERN

        def on_send(node)
          return unless inspect_call?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, node.receiver.source)
          end
        end
      end
    end
  end
end
