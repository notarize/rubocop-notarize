# frozen_string_literal: true

module RuboCop
  module Cop
    module Sidekiq
      # Enforce passing a block to Sidekiq::Testing.inline! to ensure setting does not leak to other specs
      # (https://github.com/sidekiq/sidekiq/wiki/Testing#testing-workers-inline)
      #
      # @example RequireSidekiqTestingInlineBlock: true (default)
      #
      #   # bad
      #   Sidekiq::Testing.inline!
      #   described_class.call
      #
      #   # good
      #   Sidekiq::Testing.inline! { described_class.call }
      #
      class RequireSidekiqTestingInlineBlock < Base
        MSG = 'Use Sidekiq::Testing.inline! with a block to ensure setting does not leak'

        def_node_matcher :open_call?, <<~PATTERN
          (send (...) :inline! ...)
        PATTERN

        def on_send(node)
          add_offense(node) if open_call?(node) && !node.parent.is_a?(RuboCop::AST::BlockNode)
        end
      end
    end
  end
end
