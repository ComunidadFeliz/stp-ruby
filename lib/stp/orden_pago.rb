# frozen_string_literal: true

module Stp
  class OrdenPago
    extend Savon::Model

    include Validation

    attr_accessor :institucion_contraparte, :empresa, :fecha_operacion,
                  :folio_origen, :clave_rastreo, :institucion_operante, :monto, :tipo_pago,
                  :tipo_cuenta_ordenante, :nombre_ordenante, :cuenta_ordenante,
                  :rfc_curp_ordenante, :tipo_cuenta_beneficiario, :nombre_beneficiario,
                  :cuenta_beneficiario, :rfc_curp_beneficiario, :email_beneficiario,
                  :tipo_cuenta_beneficiario_2, :nombre_beneficiario_2,
                  :cuenta_beneficiario_2, :rfc_curp_beneficiario_2, :concepto_pago,
                  :concepto_pago_2, :clave_cat_usuario_1, :clave_cat_usuario_2, :clave_pago,
                  :referencia_cobranza, :referencia_numerica, :tipo_operacion, :topologia,
                  :usuario, :medio_entrega, :prioridad, :iva, :firma

    validates :clave_rastreo, :concepto_pago, :cuenta_beneficiario, :empresa,
              :institucion_contraparte, :institucion_operante, :monto,
              :nombre_beneficiario, :referencia_numerica, :rfc_curp_beneficiario,
              :tipo_cuenta_beneficiario, :tipo_pago

    operations :registra_orden

    # causaDevolucion
    # claveCatUsuario1
    # claveCatUsuario2
    # clavePago
    # claveRastreo
    # claveRastreoDevolucion
    # conceptoPago
    # conceptoPago2
    # cuentaBeneficiario
    # cuentaBeneficiario2
    # cuentaOrdenante
    # emailBeneficiario
    # empresa
    # estado
    # facturas
    # fechaOperacion
    # firma
    # folioOrigen
    # idCliente
    # idEF
    # institucion_contraparte
    # institucionOperante
    # iva
    # medioEntrega
    # monto
    # montoInteres
    # montoOriginal
    # nombreBeneficiario
    # nombreBeneficiario2
    # nombreOrdenante
    # prioridad
    # referenciaCobranza
    # referenciaNumerica
    # reintentos
    # rfcCurpBeneficiario
    # rfcCurpBeneficiario2
    # rfcCurpOrdenante
    # tipoCuentaBeneficiario
    # tipoCuentaBeneficiario2
    # tipoCuentaOrdenante
    # tipoOperacion
    # tipoPago
    # topologia
    # tsAcuseBanxico
    # tsAcuseConfirmacion
    # tsCaptura
    # tsConfirmacion
    # tsDevolucion
    # tsDevolucionRecibida
    # tsEntrega
    # tsLiquidacion
    # usuario

    def initialize(params = {})
      self.class.client(wsdl: Stp.configuration.wsdl, ssl_verify_mode: :none)
      uri = URI.parse(Stp.configuration.wsdl)
      uri.query = nil
      self.class.global :endpoint, uri.to_s

      self.class.global :pretty_print_xml, true
      self.class.global :log, true
      self.class.global :log_level, Stp.configuration.soap_log_level
      self.class.global :env_namespace, :soapenv
      self.class.global :namespace_identifier, :h2h

      params.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end
      self.clave_rastreo = self.clave_rastreo.to_s.rjust(8, '0')
    end

    def call
      return false unless sign

      response = registra_orden(message: to_message)

      raise Error.new('Response Error', response) unless response.success?

      begin
        body = response.body[:registra_orden_response]
        body ||= response.body[:registra_ordenes_response]
        body = body[:return]
        id = body[:id].to_i

        raise Error.new(body[:descripcion_error], response) unless id > 0

        return id
      rescue NoMethodError => e
        raise Error.new("Malformed XML Error: #{e.message}", response)
      end
    end

    def to_message
      {
        orden_pago:
          instance_variables.reject { |attr| attr == :@errors }.map do |attr|
            [attr.to_s.delete('@').to_sym, instance_variable_get(attr)]
          end.to_h
      }
    end

    def to_s
      <<~HEREDOC.tr("\n", '')
        ||
        #{@institucion_contraparte}|
        #{@empresa}|
        #{@fecha_operacion}|
        #{@folio_origen}|
        #{@clave_rastreo}|
        #{@institucion_operante}|
        #{format('%.2f', (@monto || 0.0))}|
        #{@tipo_pago}|
        #{@tipo_cuenta_ordenante}|
        #{@nombre_ordenante}|
        #{@cuenta_ordenante}|
        #{@rfc_curp_ordenante}|
        #{@tipo_cuenta_beneficiario}|
        #{@nombre_beneficiario}|
        #{@cuenta_beneficiario}|
        #{@rfc_curp_beneficiario}|
        #{@email_beneficiario}|
        #{@tipo_cuenta_beneficiario_2}|
        #{@nombre_beneficiario_2}|
        #{@cuenta_beneficiario_2}|
        #{@rfc_curp_beneficiario_2}|
        #{@concepto_pago}|
        #{@concepto_pago_2}|
        #{@clave_cat_usuario_1}|
        #{@clave_cat_usuario_2}|
        #{@clave_pago}|
        #{@referencia_cobranza}|
        #{@referencia_numerica}|
        #{@tipo_operacion}|
        #{@topologia}|
        #{@usuario}|
        #{@medio_entrega}|
        #{@prioridad}|
        #{format('%.2f', (@iva || 0.0))}
        ||
      HEREDOC
    end

    private

    def sign
      return false unless valid?

      @firma = Signer.new.sign(to_s)
    end
  end
end
