# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Enforce passing a block to File.open to ensure the file is closed after use.
      #
      # @example RequireFileOpenBlock: true (default)
      #
      #   # bad
      #   file = File.open(file_path)
      #   body = file.read
      #   file.close
      #
      #   # good
      #   body = File.open(file_path) { |file| file.read }
      #
      class RequireFileOpenBlock < Base
        MSG = 'Use File.open with a block to ensure the file is closed after use.'

        def_node_matcher :open_call?, <<~PATTERN
          (send (...) :open ...)
        PATTERN

        def on_send(node)
          add_offense(node) if open_call?(node) && !node.parent.is_a?(RuboCop::AST::BlockNode)
        end
      end
    end
  end
end
