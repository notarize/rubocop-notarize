# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer T::Struct over T::ImmutableStruct.
      #
      # @example
      #
      #   # bad
      #   class User < T::ImmutableStruct
      #     const :name, String
      #   end
      #
      #   # good
      #   class User < T::Struct
      #     const :name, String
      #   end
      #
      class PreferTStruct < Base
        extend AutoCorrector

        MSG = 'Prefer `T::Struct` over `T::ImmutableStruct`.'

        # @!method immutable_struct?(node)
        def_node_matcher :immutable_struct?, <<~PATTERN
          (const (const nil? :T) :ImmutableStruct)
        PATTERN

        def on_const(node)
          return unless immutable_struct?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, 'T::Struct')
          end
        end
      end
    end
  end
end
