# frozen_string_literal: true

module Stp
  class Client
    attr_accessor :client

    def initialize
      @client = Savon::Client.new(wsdl: Stp.configuration.wsdl, ssl_verify_mode: :none) do
        wsdl.document = Stp.configuration.wsdl
        http.ssl.verify_mode = :none
        http.auth.ssl.verify_mode = :none
        http.auth.ssl.ssl_version = :SSLv3
      end
    end
  end
end
