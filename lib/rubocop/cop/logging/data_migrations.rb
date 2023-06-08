# frozen_string_literal: true

module RuboCop
  module Cop
    module Logging # should be the same as your file name
      class DataMigrations < Base
        MSG = 'Long running data migrations blocks require logging'.freeze
        RESTRICT_ON_SEND = %i[in_batches each].freeze

        def on_send(node)
          parent_node = node.parent
          
          unless block_node_has_logging?(parent_node)
            add_offense(parent_node)
          end
        end

        private

        def block_node_has_logging?(node)
          return unless node.block_type?
          logging_node = node.descendants.find { |n| NodePattern.new('(... :logger)').match(n) }
          logging_node.nil? ? false : true
        end
      end
    end
  end
end