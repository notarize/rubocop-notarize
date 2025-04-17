# frozen_string_literal: true

require 'pry'

module RuboCop
  module Cop
    module Performance
      # Enforce marking a file as # frozen_string_literal: true if the file creates any string literals
      #
      # @example RequireFrozenStringLiteral: true (default)
      #
      #   # bad
      #   my_string = "hello"
      #
      #   # good
      #   # frozen_string_literal: true
      #   my_string = "hello"
      #
      class RequireFrozenStringLiteral < Base
        include RangeHelp
        include FrozenStringLiteral

        MSG = 'Require "# frozen_string_literal: true" in any file that creates a string literal'

        def on_new_investigation
          return if processed_source.tokens.empty?
          return unless !frozen_string_literal_comment_exists? && contains_string_literal?

          add_offense(source_range(processed_source.buffer, 0, 0), message: MSG)
        end

        private

        def contains_string_literal?
          processed_source.tokens.any? { |token| token.type == :tSTRING }
        end
      end
    end
  end
end
