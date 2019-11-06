# frozen_string_literal: true

module ToxiproxyConfig
  PROXIES = JSON.parse(
    File.read("./spec/spec_help/toxiproxy_config.json"),
    symbolize_names: true # toxiproxy-ruby expect symbols
  )

  def self.proxies
    PROXIES
  end

  def self.downstream(proxy_name)
    downstream = proxies.find do |proxy|
      proxy.fetch(:name) == proxy_name
    end

    downstream.fetch(:listen)
  end
end
