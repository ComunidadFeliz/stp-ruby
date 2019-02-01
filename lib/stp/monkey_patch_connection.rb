module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTPClient
    #
    # Adapter for the HTTPClient client.
    # http://rubygems.org/gems/httpclient
    class HTTPClient < Base

      register :httpclient, :deps => %w(httpclient)

      def initialize(request)
        @request = request
        @client = ::HTTPClient.new
        @client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end
end