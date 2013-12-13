require "lita"

module Lita
  module Handlers
    class KeyValue < Handler
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
    end

    Lita.register_handler(KeyValue)
  end
end
