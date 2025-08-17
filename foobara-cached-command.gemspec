require_relative "version"

Gem::Specification.new do |spec|
  spec.name = "foobara-cached-command"
  spec.version = Foobara::CachedCommand::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "Makes it so that any foobara command will cache its result in memory and on disk."
  spec.homepage = "https://github.com/foobara/cached-command"
  spec.license = "MPL-2.0"
  spec.required_ruby_version = Foobara::CachedCommand::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*",
    "src/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.add_dependency "foobara", ">= 0.1.1", "< 2.0.0"

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
