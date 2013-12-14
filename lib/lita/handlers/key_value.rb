require "lita"

module Lita
  module Handlers
    class KeyValue < Handler
      REDIS_KEY = "kv"
      KEY_PATTERN = /[\w\._]+/

      route(/^kv\s+set\s+(#{KEY_PATTERN.source})\s+(.+)/i, :set, command: true, help: {
        "kv set KEY VALUE" => "Set KEY to VALUE."
      })

      route(/^kv\s+get\s+(#{KEY_PATTERN.source})/i, :get, command: true, help: {
        "kv get KEY" => "Get the value of KEY."
      })

      route(/^kv\s+delete\s+(#{KEY_PATTERN.source})/i, :delete, command: true, help: {
        "kv delete KEY" => "Delete KEY."
      })

      route(/^kv\s+list/i, :list, command: true, help: {
        "kv list" => "List all keys."
      })

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

        if redis.hdel(REDIS_KEY, key)
          response.reply("Deleted #{key}.")
        end
      end

      private

      def normalize_key(key)
        key.to_s.downcase.strip
      end
    end

    Lita.register_handler(KeyValue)
  end
end
