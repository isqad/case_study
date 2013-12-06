# encoding: utf-8

module CaseStudy
  module HttpStatus

    STATUSES = {
        400 => 'Bad Request',
        404 => 'Not Found',
        500 => 'Internal Server Error'
    }

    class HttpStatusException < StandardError
      class << self
        attr_reader :code, :status
      end

      def code
        self::class::code
      end

      def status
        self::class::status
      end
    end

    STATUSES.each do |code, status|
      klass_name = status.gsub /[ \-]/, ''

      klass = Class.new(HttpStatusException)
      klass.instance_variable_set(:@code, code)
      klass.instance_variable_set(:@status, status)
      const_set(klass_name, klass)
    end
  end

end
