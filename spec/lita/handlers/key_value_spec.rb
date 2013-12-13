require "spec_helper"

describe Lita::Handlers::KeyValue, lita_handler: true do
  it { routes_command("kv set foo bar").to(:set) }
  it { routes_command("kv get foo").to(:get) }
  it { routes_command("kv delete foo").to(:delete) }
  it { routes_command("kv list").to(:list) }
end
