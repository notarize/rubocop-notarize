# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Enforce using resolve_raw_query instead of resolve_field in GraphQL tests.
      # resolve_field skips the GraphQL layer and does not replicate real client behavior.
      #
      # @example AvoidResolveField: true (default)
      #
      #   # bad
      #   resolve_field(field: 'full_name', object: user, args: args, context: context)
      #
      #   # good
      #   query = "query User($id: ID!) { node(id: $id) { ... on User { full_name } } }"
      #   resolve_raw_query(query, user: user, variables: { id: user.gid })
      #
      class AvoidResolveField < Base
        MSG = '`resolve_field` skips the GraphQL layer. ' \
              'Use `resolve_raw_query` instead to replicate real client behavior.'

        def_node_matcher :resolve_field_call?, <<~PATTERN
          (send nil? :resolve_field ...)
        PATTERN

        def on_send(node)
          return unless resolve_field_call?(node)

          add_offense(node)
        end
      end
    end
  end
end
