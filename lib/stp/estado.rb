# frozen_string_literal: true

module Stp
  class Estado
    include ActiveSupport::Inflector
    EVENT_NAME = 'estado'

    include Validation

    attr_reader :id, :empresa, :folio_origen, :estado, :causa_devolucion, :fecha_liquidacion

    validates :id, :estado

    def initialize(xml)
      doc = Nokogiri::XML(xml)

      if doc.xpath('/estado').any?
        parser = Nori.new

        hash = parser.parse(xml)

        hash['estado'].each do |key, value|
          instance_variable_set("@#{key.snakecase}", value)
        end

        # unless success?
        #   raise Devolucion.new(@causa_devolucion, @id, self.class, xml)
        # end
      else
        raise Error.new('Malformed XML Error', xml)
      end
    end

    def success?
      transliterate(@estado).casecmp('exito').zero?
    end
  end
end
