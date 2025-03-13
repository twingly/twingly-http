# frozen_string_literal: true

module HttpHelpers
  def with_real_http_connections
    original_cassette = VCR.eject_cassette
    VCR.turn_off!
    WebMock.allow_net_connect!

    yield
  ensure
    WebMock.disable_net_connect!
    VCR.turn_on!
    VCR.insert_cassette(original_cassette.name) if original_cassette
  end
end
