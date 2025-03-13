# frozen_string_literal: true

require "socket"
require "timeout"

module PortProber
  module_function

  def random(host)
    server = TCPServer.new(host, 0)
    port   = server.addr[1]

    port
  ensure
    server&.close
  end

  def port_open?(ip_address, port)
    Timeout.timeout(0.5) do
      TCPSocket.new(ip_address, port).close
      true
    end
  rescue StandardError
    false
  end

  def localhost
    info = Socket.getaddrinfo("localhost",
                              80,
                              Socket::AF_INET,
                              Socket::SOCK_STREAM)

    raise "unable to translate 'localhost' for TCP + IPv4" if info.empty?

    info[0][3]
  end
end
