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

      $0 = "Bserver worker [#{Process.pid}]"

      while true

        client = @socket.accept

        #client.sync = true

        begin

          @request.parse(client)

          path = "#{@response.public_dir}#{@request.path}"

          raise '404 Not Found' unless File.exists?(path)

          @response.resource = path

        rescue => e
          $stderr.puts "[#{Time.now.utc}] [#{Process.pid}] [#{self.class.name}]: #{e.message}\n#{e.backtrace.join("\n\t")}\n"
          # Установить ошибку в response
          @response.set_error(e)
        ensure
          # при любых обстоятельствах сервер должен ответить
          @response.send_response(client)
          client.close
        end
      end
    end

  end
end