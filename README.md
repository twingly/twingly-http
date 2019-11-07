# Twingly::HTTP

Robust HTTP client

## Release workflow

* Bump the version in `lib/twingly/version.rb` in a commit, no need to push (the release task does that).

* Ensure you are signed in to RubyGems.org as [twingly][twingly-rubygems] with `gem signin`.

* Build and [publish](http://guides.rubygems.org/publishing/) the gem. This will create the proper tag in git, push the commit and tag and upload to RubyGems.

        bundle exec rake release

* Update the changelog with [GitHub Changelog Generator](https://github.com/skywinder/github-changelog-generator/) (`gem install github_changelog_generator` if you don't have it, set `CHANGELOG_GITHUB_TOKEN` to a personal access token to avoid rate limiting by GitHub). This command will update `CHANGELOG.md`. You need to commit and push manually.

        github_changelog_generator

[twingly-rubygems]: https://rubygems.org/profiles/twingly
