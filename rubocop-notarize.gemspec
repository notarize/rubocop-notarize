require_relative 'lib/rubocop/notarize/version'

Gem::Specification.new do |spec|
  spec.name          = "rubocop-notarize"
  spec.version       = RuboCop::Notarize::VERSION
  spec.authors       = ['Arturo Gonzalez', 'Matt Murphey', 'Jeremie Charrier']

  spec.summary       = 'Create Linting rules for Notarize platform'
  spec.description   = 'Custom linting rules for notarize Rupy platform'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rubocop','>= 0.92'
end