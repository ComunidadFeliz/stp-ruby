# frozen_string_literal: true

module Stp
  class Client
    attr_accessor :client

    def initialize
      @client = Savon.client(wsdl: Stp.configuration.wsdl, ssl_verify_mode: :none)
    end
  end
end
