# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # Block usage of Dir.chdir due to its thread unsafe nature
      #
      # @example BlockChdir: true (default)
      #
      #   # bad
      #   Dir.chdir(...) do
      #     ...
      #   end
      #
      #   # bad
      #   chdir ... do
      #     ...
      #   end
      #
      #   # good
      #   Use exact path or create and call method in target dir instead
      #
      class DisableChdir < Base
        MSG = 'Avoid using Dir.chdir due to thread safety issues'

        def_node_matcher :chdir?, <<~PATTERN
          (send {(const nil? :Dir) nil?} :chdir _)
        PATTERN

        def on_block(node)
          return unless chdir?(node.send_node)
          add_offense(node)
        end
      end
    end
  end
end