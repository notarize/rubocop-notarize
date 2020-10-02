# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Performance
      # Limit use of reloads
      # If you want to update an association then append/pop off the association in memory
      # If you want to
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   Book.create(shelf_id: shelf.id)
      #   shelf.reload.books
      #
      #   # good
      #   book = Book.create(shelf_id: shelf.id)
      #   shelf.books << book
      #
      class DisableReload < Base
        MSG = 'Update the model in memory instead of calling .reload'.freeze

        def_node_matcher :reload_call?, <<~PATTERN
          (send (...) :reload)
        PATTERN

        def on_send(node)
          return unless reload_call?(node)

          add_offense(node)
        end
      end
    end
  end
end