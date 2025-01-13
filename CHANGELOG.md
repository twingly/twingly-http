# Changelog

## [v0.7.1](https://github.com/twingly/twingly-http/tree/v0.7.1) (2025-01-13)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.7.0...v0.7.1)

**Merged pull requests:**

- Fix bug causing the bodies of all requests to be concatenated [\#33](https://github.com/twingly/twingly-http/pull/33) ([roback](https://github.com/roback))

## [v0.7.0](https://github.com/twingly/twingly-http/tree/v0.7.0) (2024-11-07)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.6.0...v0.7.0)

**Implemented enhancements:**

- Add capability to abort request when content-length is too large [\#21](https://github.com/twingly/twingly-http/issues/21)

**Merged pull requests:**

- Make it possible to configure max response body size [\#32](https://github.com/twingly/twingly-http/pull/32) ([roback](https://github.com/roback))

## [v0.6.0](https://github.com/twingly/twingly-http/tree/v0.6.0) (2024-11-06)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.5.0...v0.6.0)

**Closed issues:**

- SSLError: SSL\_read: unexpected eof while reading [\#28](https://github.com/twingly/twingly-http/issues/28)

**Merged pull requests:**

- Adjust user\_agent creation [\#31](https://github.com/twingly/twingly-http/pull/31) ([yendi127](https://github.com/yendi127))
- Run CI on maintained Ruby versions and update `.ruby-version` [\#30](https://github.com/twingly/twingly-http/pull/30) ([Pontus4](https://github.com/Pontus4))

## [v0.5.0](https://github.com/twingly/twingly-http/tree/v0.5.0) (2023-11-24)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.4.0...v0.5.0)

**Merged pull requests:**

- Add `final_url` to response [\#29](https://github.com/twingly/twingly-http/pull/29) ([Pontus4](https://github.com/Pontus4))
- Keep GitHub Actions files up-to-date [\#27](https://github.com/twingly/twingly-http/pull/27) ([roback](https://github.com/roback))
- Run CI with latest Rubies [\#26](https://github.com/twingly/twingly-http/pull/26) ([roback](https://github.com/roback))

## [v0.4.0](https://github.com/twingly/twingly-http/tree/v0.4.0) (2021-11-26)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.3.2...v0.4.0)

**Implemented enhancements:**

- Add `PUT`, `PATCH` and `DELETE` methods [\#24](https://github.com/twingly/twingly-http/issues/24)

**Merged pull requests:**

- Extend client with `PUT`, `PATCH` and `DELETE` methods [\#25](https://github.com/twingly/twingly-http/pull/25) ([Pontus4](https://github.com/Pontus4))

## [v0.3.2](https://github.com/twingly/twingly-http/tree/v0.3.2) (2021-06-16)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.3.1...v0.3.2)

**Merged pull requests:**

- Require `"logger"` [\#23](https://github.com/twingly/twingly-http/pull/23) ([Pontus4](https://github.com/Pontus4))
- Run CI on latest Rubies [\#22](https://github.com/twingly/twingly-http/pull/22) ([walro](https://github.com/walro))

## [v0.3.1](https://github.com/twingly/twingly-http/tree/v0.3.1) (2021-04-15)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.3.0...v0.3.1)

**Fixed bugs:**

- Tests fails under "ruby head" [\#16](https://github.com/twingly/twingly-http/issues/16)

**Merged pull requests:**

- Ruby 3.0.0 on CI [\#19](https://github.com/twingly/twingly-http/pull/19) ([walro](https://github.com/walro))
- Run Toxiproxy on Docker [\#18](https://github.com/twingly/twingly-http/pull/18) ([Pontus4](https://github.com/Pontus4))
- Run CI on GitHub Actions [\#15](https://github.com/twingly/twingly-http/pull/15) ([walro](https://github.com/walro))

## [v0.3.0](https://github.com/twingly/twingly-http/tree/v0.3.0) (2020-12-02)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.2.1...v0.3.0)

**Implemented enhancements:**

- Ruby 2.7 support [\#10](https://github.com/twingly/twingly-http/issues/10)
- Be able to use without a logger [\#9](https://github.com/twingly/twingly-http/issues/9)

**Merged pull requests:**

- Make logger optional in client [\#13](https://github.com/twingly/twingly-http/pull/13) ([Pontus4](https://github.com/Pontus4))
- Allow newer versions of faraday [\#12](https://github.com/twingly/twingly-http/pull/12) ([Pontus4](https://github.com/Pontus4))

## [v0.2.1](https://github.com/twingly/twingly-http/tree/v0.2.1) (2020-09-23)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.2.0...v0.2.1)

**Merged pull requests:**

- Update ruby version to 2.7 [\#11](https://github.com/twingly/twingly-http/pull/11) ([Chrizpy](https://github.com/Chrizpy))
- Green tests [\#7](https://github.com/twingly/twingly-http/pull/7) ([dentarg](https://github.com/dentarg))

## [v0.2.0](https://github.com/twingly/twingly-http/tree/v0.2.0) (2019-11-11)

[Full Changelog](https://github.com/twingly/twingly-http/compare/v0.1.0...v0.2.0)

**Closed issues:**

- Update the README [\#3](https://github.com/twingly/twingly-http/issues/3)
- Publish the gem [\#2](https://github.com/twingly/twingly-http/issues/2)

**Merged pull requests:**

- Be able to configure number of redirects to follow [\#6](https://github.com/twingly/twingly-http/pull/6) ([dentarg](https://github.com/dentarg))
- Be able to set headers on GET requests [\#5](https://github.com/twingly/twingly-http/pull/5) ([dentarg](https://github.com/dentarg))
- Be able to follow redirects [\#4](https://github.com/twingly/twingly-http/pull/4) ([dentarg](https://github.com/dentarg))

## [v0.1.0](https://github.com/twingly/twingly-http/tree/v0.1.0) (2019-11-07)

[Full Changelog](https://github.com/twingly/twingly-http/compare/299c53eb49768a081b65c159c1c3bf7127ec4e95...v0.1.0)

**Merged pull requests:**

- Initial import of Twingly::HTTP [\#1](https://github.com/twingly/twingly-http/pull/1) ([dentarg](https://github.com/dentarg))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
