# frozen_string_literal: true

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
        extend RuboCop::Cop::AutoCorrector

        MSG = 'Require "# frozen_string_literal: true" in any file that creates a string literal'
        STRING_TOKEN_TYPES = %i[tSTRING tSTRING_CONTENT].freeze

        def on_new_investigation
          return if processed_source.tokens.empty?
          return unless !frozen_string_literal_comment_exists? && contains_string_literal?

          add_offense(source_range(processed_source.buffer, 0, 0), message: MSG) do |corrector|
            insert_comment(corrector)
          end
        end

        private

        def contains_string_literal?
          processed_source.tokens.any? { |token| STRING_TOKEN_TYPES.any?(token.type) }
        end

        def insert_comment(corrector)
          comment = last_special_comment(processed_source)

          if comment
            corrector.insert_after(processed_source.buffer.line_range(comment.line),
                                   "\n#{FROZEN_STRING_LITERAL_ENABLED}")
          else
            corrector.insert_before(processed_source.buffer.source_range, "#{FROZEN_STRING_LITERAL_ENABLED}\n")
          end
        end

        def last_special_comment(processed_source)
          token_number = 0
          token = nil
          next_token = processed_source.tokens[token_number]

          while next_token.text.start_with?(Style::Encoding::SHEBANG) || MagicComment.parse(next_token.text).any?
            token_number += 1
            token = next_token
            next_token = processed_source.tokens[token_number]
          end

          token
        end
      end
    end
  end
end
