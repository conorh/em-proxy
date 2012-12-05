class Proxy
  def self.start_multiple(options, &blk)
    unless @trapped
      trap("TERM") { stop }
      trap("INT")  { stop }
    end
    @trapped = true

    EventMachine::start_server(options[:host], options[:port],
                               EventMachine::ProxyServer::Connection, options) do |c|
      c.instance_eval(&blk)
    end
  end

  def self.start(options, &blk)
    EM.epoll
    EM.run do

      trap("TERM") { stop }
      trap("INT")  { stop }

      EventMachine::start_server(options[:host], options[:port],
                                 EventMachine::ProxyServer::Connection, options) do |c|
        c.instance_eval(&blk)
      end
    end
  end

  def self.stop
    puts "Terminating ProxyServer"
    EventMachine.stop
  end
end
