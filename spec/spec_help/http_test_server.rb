# frozen_string_literal: true

require "timeout"

module HttpTestServer
  module_function

  TestServer = Struct.new(:pid, :url)

  def spawn(server_name, env: {}) # rubocop:disable Metrics/MethodLength
    ip_address = PortProber.localhost
    port = PortProber.random(ip_address)
    url = "http://#{ip_address}:#{port}"
    server = "spec/rack_servers/#{server_name}.ru"
    command = "bundle exec rackup --quiet --port #{port} #{server}"

    puts "starting HTTP test server: #{command}"
    pid = fork do
      $stdout.reopen File::NULL
      $stderr.reopen File::NULL
      exec env, command
    end

    Timeout.timeout(10.0) do
      sleep 0.05 until started?(pid) && PortProber.port_open?(ip_address, port)
    end

    TestServer.new(pid, url)
  end

  def stop(pid)
    Process.kill(:TERM, pid)
    Process.wait(pid)
  end

  def started?(pid)
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end
end
