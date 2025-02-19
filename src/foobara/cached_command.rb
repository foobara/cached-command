require "fileutils"

module Foobara
  module CachedCommand
    class << self
      def cache
        @cache ||= {}
      end

      def lookup_cached_data(key, file_path)
        data = if cache.key?(key)
                 cache[key]
               end

        unless data
          if File.exist?(file_path)
            data = Util.symbolize_keys(JSON.parse(File.read(file_path)))

            if data.key?(:expires_at)
              data[:expires_at] = Time.parse(data[:expires_at])
              cache[key] = data
            end
          else
            return nil
          end
        end

        if data.key?(:expires_at)
          if Time.now > data[:expires_at]
            cache.delete(key)
            FileUtils.rm_f(file_path)
            data = nil
          end
        end

        data
      end

      def write_to_cache(key, file_path, expiry, result)
        created_at = Time.now

        data = { result:, created_at: }

        if expiry && expiry != 0
          data[:expires_at] = created_at + expiry
        end

        basedir = File.dirname(file_path)

        FileUtils.mkdir_p(basedir)

        File.write(file_path, JSON.fast_generate(data))
        cache[key] = data
      end
    end

    module Execute
      def execute
        if foobara_cached_value_present?
          foobara_cached_value
        else
          foobara_write_to_cache do
            super
          end
        end
      end
    end

    include Concern

    inherited_overridable_class_attr_accessor :foobara_cache_expiry,
                                              :foobara_cache_serializer

    on_include do
      prepend Execute
    end

    def foobara_cached_value_present?
      !!foobara_cached_data
    end

    def foobara_cached_value
      foobara_cached_data[:result]
    end

    def foobara_cached_data
      @foobara_cached_data ||= CachedCommand.lookup_cached_data(
        foobara_cache_key,
        foobara_cache_path
      )
    end

    # TODO: support various caching strategies like memcached or redis, not just local files
    def foobara_cache_path
      @foobara_cache_path ||= "tmp/cached_command/#{foobara_cache_key}.json".gsub("::", "/")
    end

    # TODO: support caching based on certain inputs...
    def foobara_cache_key
      @foobara_cache_key ||= Util.underscore(self.class.name)
    end

    def foobara_write_to_cache
      result = yield

      serialized = result

      if foobara_cache_serializer
        serialized = foobara_cache_serializer.serialize(serialized)
      end

      CachedCommand.write_to_cache(foobara_cache_key, foobara_cache_path, foobara_cache_expiry, serialized)

      serialized
    end

    def foobara_cache_serializer
      return @foobara_cache_serializer if defined?(@foobara_cache_serializer)

      serializer = self.class.foobara_cache_serializer

      if serializer.is_a?(::Class)
        serializer = serializer.new
        self.class.foobara_cache_serializer = serializer
      end

      @foobara_cache_serializer = serializer
    end

    def foobara_cache_expiry
      self.class.foobara_cache_expiry
    end
  end
end
