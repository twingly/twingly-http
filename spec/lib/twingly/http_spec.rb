# frozen_string_literal: true

class CustomError < StandardError; end

RSpec.describe Twingly::HTTP::Client do
  let(:logger)            { NullLogger.new }
  let(:url)               { "http://example.org/" }
  let(:base_user_agent)   { "Twingly::HTTP/1.0" }

  let(:client) do
    client =
      described_class.new(logger: logger, base_user_agent: base_user_agent)

    client.request_id = request_id if defined?(request_id)

    client
  end

  subject(:response) do
    {
      headers: request_response.headers,
      status:  request_response.status,
      body:    request_response.body,
    }
  end

  RSpec.shared_examples "common HTTP behaviour for" do |method|
    describe "User-Agent" do
      before do
        user_agent_in_body_lamba = lambda do |request|
          { body: request.headers.fetch("User-Agent") }
        end

        stub_request(method, url)
          .to_return(&user_agent_in_body_lamba)
      end

      context "with Heroku dyno metadata" do
        around do |example|
          environment = {
            HEROKU_SLUG_COMMIT: commit,
            HEROKU_RELEASE_VERSION: release,
          }

          with_modified_env environment do
            example.run
          end
        end

        let(:commit) { "b5c40853a18a29982d65034be2ed53698112f60f" }
        let(:release) { "v112" }
        let(:expected_user_agent) do
          "#{base_user_agent} (Release/#{release}; Commit/#{commit})"
        end

        it "does request with specified user agent" do
          expect(response.fetch(:body)).to eq(expected_user_agent)
        end
      end

      context "without Heroku dyno metadata" do
        let(:expected_user_agent) do
          "Twingly::HTTP/1.0 (Release/unknown_heroku_release_version; "\
          "Commit/unknown_heroku_slug_commit)"
        end

        it "does request with specified user agent" do
          expect(response.fetch(:body)).to eq(expected_user_agent)
        end
      end
    end

    describe "X-Request-Id" do
      let(:request_id) { "ec4709c2-651a-412a-a2dd-b59c9fe09c3b" }

      before do
        request_headers_in_body_lamba = lambda do |request|
          { body: request.headers.to_json }
        end

        stub_request(method, url)
          .to_return(&request_headers_in_body_lamba)
      end

      let(:actual_request_headers) { JSON.parse(response.fetch(:body)) }
      let(:actual_request_id) { actual_request_headers.fetch("X-Request-Id") }

      it "does request with specified request id" do
        expect(actual_request_id).to eq(request_id)
      end

      ["", " ", nil].each do |empty_request_id|
        context "when the request id is #{empty_request_id}" do
          let(:request_id) { empty_request_id }

          it { expect(actual_request_headers).not_to have_key("X-Request-Id") }
        end
      end
    end

    context "when given a host that redirects" do
      let(:url) { "http://this.redirects" }
      let(:stub_redirects) do
        lambda do |start_url, base_redir_url, times|
          times.times do |n|
            redir_url = n == 0 ? start_url : "#{base_redir_url}#{n}"

            stub_request(:any, redir_url)
              .to_return(status: 302,
                         headers: { "Location" => "#{base_redir_url}#{n + 1}" })
          end

          stub_request(:any, "#{base_redir_url}#{times}").to_return(status: 200)
        end
      end

      context "when following redirects" do
        before do
          client.follow_redirects = true

          stub_redirects.call(url, "http://redirect.", 1)
        end

        it do
          is_expected.to match(headers: {},
                               status: 200,
                               body: "")
        end
      end

      context "when not following redirects" do
        before do
          client.follow_redirects = false

          stub_redirects.call(url, "http://redirect.", 1)
        end

        it do
          is_expected.to match(headers: { "location" => "http://redirect.1" },
                               status: 302,
                               body: "")
        end
      end

      context "when given a host that redirects many times" do
        before do
          redirects = 5
          client.follow_redirects = true
          client.follow_redirects_limit = redirects + 1

          stub_redirects.call(url, "http://redirect.", redirects)
        end

        it do
          is_expected.to match(headers: {},
                               status: 200,
                               body: "")
        end
      end

      context "when given a host that redirects too many times" do
        before do
          client.follow_redirects = true
          redirects = client.follow_redirects_limit + 1

          stub_redirects.call(url, "http://redirect.", redirects)
        end

        it do
          expect { subject }
            .to raise_error(Twingly::HTTP::RedirectLimitReached)
        end
      end
    end

    context "when given a host that times out" do
      before do
        # enable (quick) retries
        client.number_of_retries = 2
        client.retry_interval = 0.01
      end

      context "when creating the connection" do
        before do
          stub_request(:any, "example.org").to_timeout
        end

        it "should raise exception" do
          expect { subject }
            .to raise_error(Twingly::HTTP::ConnectionError)
        end

        it "does not retry" do
          callback = double("callback").as_null_object

          client.on_retry_callback = callback
          expect { subject } # issue the HTTP request
            .to raise_error(Twingly::HTTP::ConnectionError)

          expect(callback).not_to have_received(:call)
        end
      end

      context "when reading the response" do
        before do
          stub_request(:any, "example.org").to_raise(Net::ReadTimeout)
        end

        it "should raise exception" do
          expect { subject }
            .to raise_error(Twingly::HTTP::ConnectionError)
        end

        it "does not retry" do
          callback = double("callback").as_null_object

          client.on_retry_callback = callback
          expect { subject } # issue the HTTP request
            .to raise_error(Twingly::HTTP::ConnectionError)

          expect(callback).not_to have_received(:call)
        end
      end
    end

    context "when given a host that we can't connect to" do
      let(:body)      { "retries ftw" }
      let(:exception) { SocketError }

      before do
        stub_request(:any, "example.org")
          .to_raise(exception).then
          .to_return(body: body)
      end

      it "should raise exception" do
        expect { subject }
          .to raise_error(Twingly::HTTP::ConnectionError)
      end

      context "with retries enabled" do
        before do
          client.number_of_retries = 2
          client.retry_interval = 0.01
        end

        it do
          is_expected.to match(headers: {},
                               status: 200,
                               body: body)
        end

        it 'calls the "on retry" callback' do
          callback = double("callback").as_null_object

          client.on_retry_callback = callback
          subject # issue the HTTP request

          expect(callback)
            .to have_received(:call)
            .with(any_args, exception)
        end

        context "with user-defined retryable exception" do
          let(:exception) { CustomError }

          before do
            client.retryable_exceptions = [exception]
          end

          it do
            is_expected.to match(headers: {},
                                 status: 200,
                                 body: body)
          end

          it 'calls the "on retry" callback' do
            callback = double("callback").as_null_object

            client.on_retry_callback = callback
            subject # issue the HTTP request

            expect(callback)
              .to have_received(:call)
              .with(any_args, exception)
          end
        end
      end
    end

    context "when an error occurs" do
      let(:error) { StandardError.new("Error message") }

      before do
        stub_request(:any, url).to_raise(error)
      end

      specify do
        expect { request_response }
          .to raise_error(error)
      end
    end

    context "when used with stdout logger" do
      # to let rspec temporarily replace $stdout so to_stdout works
      let(:logger)     { TestLogger.logger_with_log_level_from_env($stdout) }
      let(:request_id) { "ec4709c2-651a-412a-a2dd-b59c9fe09c3b" }
      let(:dyno_id)    { "f68a2c22-35d3-44cd-92ee-084c16fab054" }
      let(:commit)     { "b5c40853a18a29982d65034be2ed53698112f60f" }
      let(:release)    { "v112" }

      describe "request" do
        let(:expected_log_row) do
          "at=info " \
          "source=upstream-request " \
          "method=#{method.to_s.upcase} " \
          "url=#{url} " \
          "request_id=#{request_id} " \
          "release=#{release}"
        end

        around do |example|
          environment = {
            HEROKU_RELEASE_VERSION: release,
          }

          with_modified_env environment do
            example.run
          end
        end

        specify do
          expect { request_response }
            .to output(Regexp.new(expected_log_row)).to_stdout
        end
      end

      describe "response" do
        context "when no error occurs" do
          let(:expected_log_row) do
            "at=info " \
            "source=upstream-response " \
            "status=200 " \
            "request_id=#{request_id} " \
            "release=#{release}"
          end

          around do |example|
            environment = {
              HEROKU_RELEASE_VERSION: release,
            }

            with_modified_env environment do
              example.run
            end
          end

          specify do
            expect { request_response }
              .to output(Regexp.new(expected_log_row)).to_stdout
          end
        end
      end

      context "with default log level" do
        specify do
          expect { request_response }.to_not output(/at=debug/).to_stdout
        end
      end

      context "with debug log level" do
        around do |example|
          with_modified_env LOG_LEVEL: "DEBUG" do
            example.run
          end
        end

        specify do
          expect { request_response }.to output(/at=debug/).to_stdout
        end
      end
    end

    context "when a maximum url size is set" do
      let(:max_url_size_bytes) { 64 }

      before do
        client.max_url_size_bytes = max_url_size_bytes
      end

      context "when URL is below limit" do
        let(:url) { "http://example.org/short-url" }
        let!(:stubbed_request) { stub_request(:any, url) }

        before { request_response }

        it "does request with specified url" do
          expect(stubbed_request).to have_been_requested
        end
      end

      context "when URL is above limit" do
        let(:url) { "http://example.org/#{'a' * max_url_size_bytes}" }

        it "raises an error" do
          expect { request_response }
            .to raise_error(Twingly::HTTP::UrlSizeLimitExceededError)
        end
      end
    end

    context "with unreliable hosts" do
      let(:example_timeout) { 1.0 }

      before do
        VCR.eject_cassette
        WebMock.allow_net_connect!
        VCR.turn_off!
      end

      after do
        VCR.turn_on!
        WebMock.disable_net_connect!
      end

      context "when given a slow host" do
        let(:toxiproxy) { "http_host" }
        let(:url)       { "http://#{ToxiproxyConfig.downstream(toxiproxy)}/" }

        describe "open/read timeout" do
          before { client.http_timeout = 0.1 }

          around do |example|
            Toxiproxy[toxiproxy].toxic(:timeout, timeout: 0).apply do
              Timeout.timeout(example_timeout) do
                example.run
              end
            end
          end

          it "should raise exception" do
            expect { subject }
              .to raise_error(Twingly::HTTP::ConnectionError)
          end
        end
      end

      context "when given an unreachable host" do
        # Assigned 127.0.0.2 since we have seen SJ route 192.0.2.0/24
        # https://en.wikipedia.org/wiki/Reserved_IP_addresses#IPv4
        let(:url) { "http://127.0.0.2/" }

        describe "connection open timeout" do
          before { client.http_open_timeout = 0.1 }

          around do |example|
            Timeout.timeout(example_timeout) do
              example.run
            end
          end

          it "should raise exception after a certain amount of time" do
            expect { subject }
              .to raise_error(Twingly::HTTP::ConnectionError)
          end
        end
      end
    end
  end

  describe "#post", vcr: Fixture.post_example_org do
    include_examples "common HTTP behaviour for", :post

    let(:post_body)    {}
    let(:post_headers) { {} }
    let(:request_response) do
      client.post(url, body: post_body, headers: post_headers)
    end

    describe "headers" do
      let(:headers) do
        {
          "Content-Type" => "application/json",
        }
      end

      before do
        headers_in_body_lamba = lambda do |request|
          { body: request.headers.to_json }
        end

        stub_request(:post, url)
          .to_return(&headers_in_body_lamba)
      end

      it "does request with specified headers" do
        expect(JSON.parse(response.fetch(:body))).to include(post_headers)
      end
    end

    describe "body" do
      let(:post_body) { { "some" => "json" }.to_json }

      before do
        request_body_in_body_lamba = lambda do |request|
          { body: request.body }
        end

        stub_request(:post, url)
          .to_return(&request_body_in_body_lamba)
      end

      it "does request with specified body" do
        expect(response.fetch(:body)).to include(post_body)
      end
    end
  end

  describe "#get", vcr: Fixture.example_org do
    include_examples "common HTTP behaviour for", :get

    let(:request_response) do
      client.get(url)
    end

    it do
      is_expected.to match(headers: be_an_instance_of(Hash),
                           status: 200,
                           body: match(/Example Domain/))
    end

    # https://github.com/lostisland/faraday/pull/513#issuecomment-254794047
    context "handle non-properly UTF-8 encoded characters in query parameters",
            vcr: Fixture.example_org(ignore_params: "foo") do
      let(:url) { "http://example.org/?foo=bar%E9+baz%E8" }

      it do
        is_expected.to match(headers: be_an_instance_of(Hash),
                             status: 200,
                             body: match(/Example Domain/))
      end
    end

    describe "headers" do
      let(:headers) do
        {
          "Content-Type" => "application/json",
        }
      end

      let(:request_response) do
        client.get(url, headers: headers)
      end

      before do
        headers_in_body_lamba = lambda do |request|
          { body: request.headers.to_json }
        end

        stub_request(:get, url)
          .to_return(&headers_in_body_lamba)
      end

      it "does request with specified headers" do
        expect(JSON.parse(response.fetch(:body))).to include(headers)
      end
    end

    describe "params" do
      let(:params) do
        {
          foo: "bar baz",
          size: 10,
        }
      end

      context "a URL without params" do
        let(:url) { "http://www.example.org/" }

        let!(:stubbed_request) do
          stub_request(:get, url).with(query: params)
        end

        before { client.get(url, params: params) }

        it "adds the given params to the URL" do
          expect(stubbed_request).to have_been_requested
        end
      end

      context "a URL with params" do
        let(:scheme_and_host) { "http://www.example.org" }
        let(:url)             { "#{scheme_and_host}?param_in_url=yes" }
        let(:expected_params) { params.merge(param_in_url: "yes") }

        let!(:stubbed_request) do
          stub_request(:get, scheme_and_host).with(query: expected_params)
        end

        before { client.get(url, params: params) }

        it "merges the given params with those in the URL" do
          expect(stubbed_request).to have_been_requested
        end
      end
    end
  end
end
