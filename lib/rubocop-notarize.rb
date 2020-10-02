# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/notarize'
require_relative 'rubocop/notarize/version'
require_relative 'rubocop/notarize/inject'

RuboCop::Notarize::Inject.defaults!

require_relative 'rubocop/cop/notarize_cops'
