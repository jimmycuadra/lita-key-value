require "lita"

module Lita
  module Handlers
    class KeyValue < Handler
      REDIS_KEY = "kv"
      KEY_PATTERN = /[\w\._]+/

      def self.default_config(config)
        config.key_pattern = nil
        config.key_normalizer = nil
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
      end

      on :loaded, :define_routes

      def define_routes(payload)
        pattern = config.key_pattern || KEY_PATTERN
        self.class.define_routes(pattern.source)
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

      private

      def config
        Lita.config.handlers.key_value
      end

      def normalize_key(key)
        normalizer = config.key_normalizer

        if normalizer.respond_to?(:call)
          normalizer.call(key)
        else
          key.to_s.downcase.strip
        end
      end
    end

    Lita.register_handler(KeyValue)
  end
end
