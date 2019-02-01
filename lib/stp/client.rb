# frozen_string_literal: true

module Stp
  class Client
    attr_accessor :client

    def initialize
      # @client = Savon.client(wsdl: Stp.configuration.wsdl, ssl_verify_mode: :none)
      @client = Savon::Client.new do
        wsdl.document = Stp.configuration.wsdl
        http.auth.ssl.verify_mode = :none
        http.auth.ssl.ssl_version = :SSLv3
      end
    end
  end
end
