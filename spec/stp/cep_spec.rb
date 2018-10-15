# frozen_string_literal: true

require 'spec_helper'
require 'support/signer_helpers'
require 'support/log_interceptor'
require 'savon/mock/spec_helper'

RSpec.describe Stp::Cep do
  include SignerHelpers
  include Savon::SpecHelper

  def build_cep
    Stp::Cep.new(
      clave_institucion_beneficiario: '40062',
      clave_institucion_ordenante: '40072',
      clave_rastreo: '7279MAP3201809300645472392',
      cuenta_beneficiario: '062580001241176661',
      fecha: '20180930',
      monto: 6293.00,
      tipo_operacion: 'C'
    )
  end

  after :each do
    Stp.reset
  end

  context 'when given incomplete attributes' do
    it 'is not valid' do
      cep = Stp::Cep.new

      expect(cep.valid?).to be false
    end
  end

  context 'when given valid attributes' do
    it 'is valid' do
      cep = build_cep

      expect(cep.valid?).to be true
    end

    # it 'generates the xml correctly' do
    #   cep = build_cep

    #   cep.class.send(:global, :logger, LogInterceptor)

    #   request = File.read('spec/fixtures/consulta_cep_lote_request.xml')

    #   # TODO: this is slow because it calls the SOAP service
    #   begin
    #     cep.call
    #   rescue Exception => e
    #   end

    #   expect(LogInterceptor.get_intercepted_request).to eq request
    # end

    it 'gets a response' do
      savon.mock!

      cep = build_cep

      response = File.read('spec/fixtures/cep_lote_response.xml')

      savon.expects(:consulta_cep_lote).with(message: cep.to_message)
           .returns(response)

      expect(cep.call[:nombre_beneficiario]).to eq 'MARTIN DELFINO RUEDA LOPEZ'

      savon.unmock!
    end
  end
end
