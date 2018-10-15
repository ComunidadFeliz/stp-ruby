module Stp
  class Cep
    extend Savon::Model

    include Validation

    attr_accessor :clave_institucion_beneficiario, :clave_institucion_ordenante,
    :clave_rastreo, :cuenta_beneficiario, :fecha, :monto, :tipo_operacion,
    :nombre_institucion_beneficiario, :nombre_institucion_ordenante, :cadena_original,
    :concepto_pago, :cuenta_ordenante, :fecha_captura, :fecha_operacion, :hora, :iva,
    :nombre_beneficiario, :nombre_inst_beneficiaria, :nombre_inst_ordenante,
    :nombre_ordenante, :referencia_numerica, :rfc_curp_beneficiario, :rfc_curp_ordenante,
    :sello_digital, :serie_certificado, :tipo_pago, :estado_consulta, :parametros_consulta, :url

    validates :clave_institucion_beneficiario, :clave_institucion_ordenante, :clave_rastreo,
      :cuenta_beneficiario, :fecha, :monto, :tipo_operacion

    def initialize(params = {})
      self.class.client wsdl: Stp.configuration.wsdl

      self.class.global :pretty_print_xml, true
      self.class.global :log, true
      self.class.global :log_level, Stp.configuration.soap_log_level
      self.class.global :env_namespace, :soapenv
      self.class.global :namespace_identifier, :h2h

      self.class.operations :consulta_cep_lote

      params.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end
    end

    def call
      response = consulta_cep_lote(message: to_message)

      raise Error.new('Response Error', response) unless response.success?

      begin
        body = response.body[:consulta_cep_lote_response]
        body = body[:return][:cda]
        return body
      rescue NoMethodError => e
        raise Error.new("Malformed XML Error: #{e.message}", response)
      end
    end

    def to_message
      {
        parametros_consulta:
          instance_variables.select { |attr| attr != :@errors}.map do |attr|
            [attr.to_s.delete('@').to_sym, instance_variable_get(attr)]
          end.to_h
      }
    end
  end
end
