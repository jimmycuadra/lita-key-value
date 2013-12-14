require "spec_helper"

describe Lita::Handlers::KeyValue, lita_handler: true do
  it { routes_command("kv set foo bar").to(:set) }
  it { routes_command("kv get foo").to(:get) }
  it { routes_command("kv delete foo").to(:delete) }
  it { routes_command("kv list").to(:list) }

  it "sets and gets keys" do
    send_command("kv set foo bar")
    expect(replies.last).to eq("Set foo to bar.")
    send_command("kv get foo")
    expect(replies.last).to eq("bar")
  end

  it "treats keys as case insensitive and values as case sensitive" do
    send_command("kv set FoO bAr")
    send_command("kv get fOo")
    expect(replies.last).to eq("bAr")
  end

  describe "#get" do
    it "returns a warning if the key was never set" do
      send_command("kv get foo")
      expect(replies.last).to eq("No value for key foo.")
    end
  end
end
