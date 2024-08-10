# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name        = 'mcake'
  gem.version     = '0.0.1'
  gem.authors     = ['Markus Schirp']
  gem.email       = ['mbj@schirp-dso.com']
  gem.description = 'Minimal parallell m(c)ake.'
  gem.summary     = ''
  gem.homepage    = 'https://github.com/mbj/mcake'
  gem.license     = 'MIT'

  gem.require_paths = %w[lib]

  gem.files            = Dir.glob('lib/**/*').sort
  gem.extra_rdoc_files = %w[LICENSE]
  gem.executables      = %w[mutant]

  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.required_ruby_version = '>= 3.0'

  gem.add_runtime_dependency('adamantium', '~> 0.2.0')
  gem.add_runtime_dependency('anima',      '~> 0.3.2')
  gem.add_runtime_dependency('variable',   '~> 0.0.1')

  gem.add_development_dependency('mutant', '~> 0.12.4')
end
