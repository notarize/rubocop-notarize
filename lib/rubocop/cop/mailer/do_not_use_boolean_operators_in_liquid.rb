# frozen_string_literal: true

module RuboCop
	module Cop
		module Mailer
			# For Liquid template files, use the words `or` and `and` instead of
			# the Ruby boolean operators `||` and `&&` because Liquid does not
      # support the and/or operators.
			#
			# This cop only inspects files whose path ends with `.liquid`.
			# @example DoNotUseBooleanOperatorsInLiquid: true (default)
      #
      #   # bad
      #   {% if foo || bar %} ... {% endif %}
      #
      #   # good
      #   {% if foo or bar %} ... {% endif %}
			class DoNotUseBooleanOperatorsInLiquid < Base
				extend RuboCop::Cop::AutoCorrector

				MSG_OR = "Use 'or' instead of ||"
				MSG_AND = "Use 'and' instead of &&"

				def on_new_investigation
					return unless liquid_file?

					source = processed_source.buffer.source

					source.to_enum(:scan, /\|\||&&/).each do
						match = Regexp.last_match
						begin_pos = match.begin(0)
						end_pos = match.end(0)
						range = Parser::Source::Range.new(processed_source.buffer, begin_pos, end_pos)

						operator = match[0]
						message = operator == '||' ? MSG_OR : MSG_AND

						add_offense(range, message: message) do |corrector|
							replacement = operator == '||' ? 'or' : 'and'
							corrector.replace(range, replacement)
						end
					end
				end

				private

				def liquid_file?
					filename = processed_source.buffer.name
					filename && filename.end_with?('.liquid')
				end
			end
		end
	end
end
