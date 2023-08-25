# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Enforce a maximum file line limit.
      #
      # @example FileLineLimit:
      #
      #   # bad
      #   # (assuming a maximum limit of 1180 lines)
      #   This file contains more than 1180 lines of code.
      #
      #   # good
      #   # (assuming a maximum limit of 1180 lines)
      #   This file does not exceed 1180 lines of code.
      #   Rule does not apply to spec files.
      #
      class FileLineLimit < Base
        MSG = 'This file contains more than the limit of %{max} lines of code.'
        MAX_LINES = 1180

        def on_new_investigation
          return unless processed_source.valid_syntax?

          file_lines = processed_source.lines.count

          return if file_lines <= MAX_LINES || processed_source_buffer.name =~ /_spec\.rb$/

          add_offense(nil, location: nil, message: format(MSG, max: MAX_LINES))
        end
      end
    end
  end
end

