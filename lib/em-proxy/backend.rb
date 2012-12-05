module EventMachine
  module ProxyServer
    class Backend < EventMachine::Connection
      attr_accessor :plexer, :name, :debug, :tls

      def initialize(debug = false, tls = false)
        @debug = debug
        @tls = tls
        @connected = EM::DefaultDeferrable.new
      end

      def post_init
        if @tls
          start_tls
        end
      end

      def connection_completed
        debug [@name, :conn_complete]
        @plexer.connected(@name)
        @connected.succeed
      end

      def receive_data(data)
        debug [@name, data]
        @plexer.relay_from_backend(@name, data)
      end

      # Buffer data until the connection to the backend server
      # is established and is ready for use
      def send(data)
        @connected.callback { send_data data }
      end

      # Notify upstream plexer that the backend server is done
      # processing the request
      def unbind
        debug [@name, :unbind]
        @plexer.unbind_backend(@name)
      end

      private

      def debug(*data)
        return unless @debug
        require 'pp'
        pp data
        puts
      end
    end
  end
end