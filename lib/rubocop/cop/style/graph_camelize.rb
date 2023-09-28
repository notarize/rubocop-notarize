# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Do not use the GraphQL camelize option as we always want the default value (true).
      #
      # @example GraphCamelize: true (default)
      #
      #   # bad
      #   field :updated_at, String, null: true, camelize: false
      #
      #   # good
      #   field :updated_at, String, null: true
      #
      class GraphCamelize < Base
        extend AutoCorrector

        MSG = 'Do not use the camelize option.'
        RESTRICT_ON_SEND = %i[argument field].freeze
        INCORRECT_OPTION = 'camelize'

        def on_send(node)
          node.children.each do |argument|
            next unless argument.respond_to?(:type) && argument.type == :hash

            argument.children.each do |pair|
              next unless pair.key.value.to_s == INCORRECT_OPTION

              add_offense(pair) do |corrector|
                corrector.remove(get_range_to_remove(pair))
              end
            end
          end
        end

        private

        def get_range_to_remove(node)
          left_node = node.left_sibling || node.parent&.left_sibling
          begin_pos = left_node&.source_range&.end_pos || node.source_range.begin_pos
          end_pos = node.source_range.end_pos
          Parser::Source::Range.new(node.source_range.source_buffer, begin_pos, end_pos)
        end
      end
    end
  end
end
