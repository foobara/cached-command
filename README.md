# Foobara::CachedCommand

## Installation

Typical stuff... either add `gem "foobara-cached_command"` to your Gemfile or `spec.add_dependency "foobara-cached_command"` 
to your .gemspec or `gem install foobara-cached_command` depending on what you're up to.

## Usage

Will automatically cache any command to memory and disk if you include it.

```ruby
SomeCommand.include(Foobara::CachedCommand)
```

Note that for now this only caches the results of the command without making use of the inputs.
This is because for now I just want this for a few commands that don't take any inputs.

If somebody wants the ability to cache different outputs for different inputs let me know and I'd love to add
such a feature.

## Contributing

Bug reports and pull requests are welcome on GitHub
at https://github.com/foobara/foobara-cached-command

## License

This project is licensed under the MPL-2.0 license. Please see LICENSE.txt for more info.
