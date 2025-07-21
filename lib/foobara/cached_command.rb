require "foobara/all"
require "foobara/command_connectors"

Foobara::Util.require_directory "#{__dir__}/../../src"

module Foobara
  module CachedCommand
    class << self
      def reset_all
        Foobara.raise_if_production!("reset_all")

        FileUtils.rm_rf "tmp/cached_command/"
        Foobara::CachedCommand.cache.clear
      end
    end
  end
end
