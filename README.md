# Twingly::HTTP

[![GitHub Build Status](https://github.com/twingly/twingly-http/workflows/CI/badge.svg?branch=master)](https://github.com/twingly/twingly-http/actions)

Robust HTTP client, tailored by Twingly.

## Getting Started

Install the gem:

    gem install twingly-http

Example "one-liner" usage:

```
ruby -rlogger -rtwingly/http -e '\
    logger = Logger.new($stdout); logger.level = :INFO; \
    puts Twingly::HTTP::Client.new(logger: logger, \
    base_user_agent: "").get("http://example.org").status'
```

Example `irb` usage:

```
irb -rlogger -rtwingly/http
```
```ruby
logger = Logger.new($stdout); logger.level = :INFO
client = Twingly::HTTP::Client.new(logger: logger, base_user_agent: "")
client.get("http://example.org").status
```

## Tests

The tests require [Toxiproxy](https://github.com/Shopify/toxiproxy)

    docker-compose up

Run tests with

    bundle exec rake

## Release workflow

* Bump the version in `lib/twingly/version.rb` in a commit, no need to push (the release task does that).

* Ensure you are signed in to RubyGems.org as [twingly][twingly-rubygems] with `gem signin`.

* Build and [publish](http://guides.rubygems.org/publishing/) the gem. This will create the proper tag in git, push the commit and tag and upload to RubyGems.

        bundle exec rake release

* Update the changelog with [GitHub Changelog Generator](https://github.com/skywinder/github-changelog-generator/) (`gem install github_changelog_generator` if you don't have it, set `CHANGELOG_GITHUB_TOKEN` to a personal access token to avoid rate limiting by GitHub). This command will update `CHANGELOG.md`. You need to commit and push manually.

        github_changelog_generator

[twingly-rubygems]: https://rubygems.org/profiles/twingly
