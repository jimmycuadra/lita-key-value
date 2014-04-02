require "spec_helper"

describe Lita::Handlers::KeyValue, lita_handler: true do
  it { routes_command("kv set foo bar").to(:set) }
  it { routes_command("kv get foo").to(:get) }
  it { routes_command("kv delete foo").to(:delete) }
  it { routes_command("kv list").to(:list) }
  it { routes_command("kv search foo").to(:search) }

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

  it "deletes keys and returns a warning when the empty key is accessed" do
    send_command("kv set foo bar")
    send_command("kv delete foo")
    send_command("kv get foo")
    expect(replies.last).to eq("No value for key foo.")
  end

  it "lists keys" do
    send_command("kv set foo bar")
    send_command("kv set baz blah")
    send_command("kv set carl pug")
    send_command("kv list")
    expect(replies.last).to eq("baz, carl, foo")
  end

  describe "#delete" do
    it "replies with a warning if the key isn't stored" do
      send_command("kv delete foo")
      expect(replies.last).to eq("foo isn't stored.")
    end
  end

  describe "#list" do
    it "replies with a warning if there are no stored keys" do
      send_command("kv list")
      expect(replies.last).to eq("No keys are stored.")
    end
  end

  describe "#search" do
    it "returns keys containing the search term" do
      send_command("kv set foo bar")
      send_command("kv set bazfoo bar")
      send_command("kv set foobaz bar")
      send_command("kv set blahfoobaz bar")
      send_command("kv set hello.amaninacan lol")
      send_command("kv search foo")
      expect(replies.last).to eq("bazfoo, blahfoobaz, foo, foobaz")
    end

    it "replies with a warning if there are no matching keys" do
      send_command("kv search foo")
      expect(replies.last).to eq("No matching keys found.")
    end
  end

  context "with a custom key handler and normalizer" do
    before do
      Lita.config.handlers.key_value.tap do |config|
        config.key_pattern = /[\w-]+/
        config.key_normalizer = proc { |key| "~#{key}~" }
      end

      described_class.routes.clear
      subject.define_routes({})
    end

    it "allows a custom key pattern and normalizer" do
      send_command("kv set hello-world it works")
      send_command("kv get hello-world")
      expect(replies.last).to eq("it works")
    end
  end
end
