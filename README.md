# lita-key-value

[![Build Status](https://travis-ci.org/jimmycuadra/lita-key-value.png?branch=master)](https://travis-ci.org/jimmycuadra/lita-key-value)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-key-value.png)](https://codeclimate.com/github/jimmycuadra/lita-key-value)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-key-value/badge.png)](https://coveralls.io/r/jimmycuadra/lita-key-value)


**lita-key-value** is a handler for [Lita](http://lita.io/) that stores snippets of text.

## Installation

Add lita-key-value to your Lita instance's Gemfile:

``` ruby
gem "lita-key-value"
```

## Configuration

### Optional attributes

* `key_pattern` (Regexp) - Determines what Lita will recognize as a valid key. Default: `/[\w\._]+/`.
* `key_normalizer` (Proc) - A custom callable that determines how each key will be normalized before being stored in Redis. The proc should take one argument, the key as matched via regular expression, and return one value, the normalized version of the key.

### Example

``` ruby
Lita.configure do |config|
  config.handlers.key_value.key_pattern = /[\w-]+/
  config.handlers.key_value.key_normalizer = proc { |key| "~#{key}~" }
end
```

## Usage

Set a key:

```
You: Lita, kv set google http://www.google.com/
Lita: Set google to https://www.google.com/.
```

Get a key:

```
You: Lita, kv get google
Lita: https://www.google.com/
```

Delete a key:

```
You: Lita, kv delete google
Lita: Deleted google.
```

List keys:

```
You: Lita, kv list
Lita: google, heart, something.else
```

Keys are restricted to alphanumeric characters, underscores, and periods. Values can contain character.

## License

[MIT](http://opensource.org/licenses/MIT)
