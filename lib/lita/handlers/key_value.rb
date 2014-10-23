require "lita"

module Lita
  module Handlers
    class KeyValue < Handler
      REDIS_KEY = "kv"

      config :key_pattern, type: Regexp, default: /[\w\._]+/
      config :key_normalizer do
        validate do |value|
          "must be a callable object" unless value.respond_to?(:call)
        end
      end

      def self.define_routes(pattern)
        route(/^kv\s+set\s+(#{pattern})\s+(.+)/i, :set, command: true, help: {
          "kv set KEY VALUE" => "Set KEY to VALUE."
        })

        route(/^kv\s+get\s+(#{pattern})/i, :get, command: true, help: {
          "kv get KEY" => "Get the value of KEY."
        })

        route(/^kv\s+delete\s+(#{pattern})/i, :delete, command: true, help: {
          "kv delete KEY" => "Delete KEY."
        })

        route(/^kv\s+list/i, :list, command: true, help: {
          "kv list" => "List all keys."
        })

        route(/^kv\s+search\s+(#{pattern})/i, :search, command: true, help: {
          "kv search KEY" => "Search for keys containing KEY."
        })
      end

      on :loaded, :define_routes

      def define_routes(payload)
        self.class.define_routes(config.key_pattern.source)
      end

      def set(response)
        key, value = response.matches.first
        key = normalize_key(key)
        redis.hset(REDIS_KEY, key, value)
        response.reply("Set #{key} to #{value}.")
      end

      def get(response)
        key = normalize_key(response.matches.first.first)
        value = redis.hget(REDIS_KEY, key)

        if value
          response.reply(value)
        else
          response.reply("No value for key #{key}.")
        end
      end

      def delete(response)
        key = normalize_key(response.matches.first.first)

        if redis.hdel(REDIS_KEY, key) >= 1
          response.reply("Deleted #{key}.")
        else
          response.reply("#{key} isn't stored.")
        end
      end

      def list(response)
        keys = redis.hkeys(REDIS_KEY)

        if keys.empty?
          response.reply("No keys are stored.")
        else
          response.reply(keys.sort.join(", "))
        end
      end

      def search(response)
        search_term = response.matches.first.first
        keys = redis.hkeys(REDIS_KEY)

        matching_keys = keys.select { |key| key.include?(search_term) }

        if matching_keys.empty?
          response.reply("No matching keys found.")
        else
          response.reply(matching_keys.sort.join(", "))
        end
      end

      private

      def config
        Lita.config.handlers.key_value
      end

      def normalize_key(key)
        normalizer = config.key_normalizer

        if normalizer
          normalizer.call(key)
        else
          key.to_s.downcase.strip
        end
      end
    end

    Lita.register_handler(KeyValue)
  end
end
