# encoding: utf-8

module CaseStudy
  # Public: воркер процесс - обработчик запроса
  class RequestHandler

    # Public: конструктор
    #
    # socket - TCPSocket
    def initialize(socket)
      @socket = socket
      @response = Response.new
      @request = Request.new
    end

    # Public: обработка входящего запроса
    def handle
      client = @socket.accept

      client.sync = true

      begin
        @request.parse(client)

        path = "#{@response.public_dir}#{@request.path}"

        raise '404 Not Found' unless File.exists?(path)

        @response.resource = path
      rescue => e
        @response.set_error(e)
      ensure
        @response.send_response(client)
      end
    end

  end
end
