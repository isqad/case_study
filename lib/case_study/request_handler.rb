# encoding: utf-8

module CaseStudy
  # Public: воркер процесс - обработчик запроса
  class RequestHandler
    include Logger

    # Public: порядковый номер рабочего
    attr_accessor :number

    # Public: конструктор
    #
    # socket - TCPSocket
    # number - порядковый номер
    def initialize(socket, number)

      @socket = socket

      @response = WEBrick::HTTPResponse.new(
        :Logger => self,
        :HTTPVersion => '1.1',
        :ServerSoftware => 'Bserver'
      )

      @request = WEBrick::HTTPRequest.new(:Logger => self)

      @number = number
    end

    # Public: обработка входящего запроса
    def handle

      $0 = "Bserver worker ##{@number}"

      while true
        begin
          # блокировка IO
          client, addr = @socket.accept

          client.sync = true

          @request.parse client

          @response.body = File.open('/tmp/index.html', 'r')

        rescue WEBrick::HTTPStatus::EOFError, WEBrick::HTTPStatus::RequestTimeout => e
          # Установить ошибку в response
          @response.set_error(e)
        rescue => e
          error(e)
          @response.set_error(e)
        ensure
          # при любых обстоятельствах сервер должен ответить
          @response.send_response(client)
          client.close
        end
      end
    end

    # Public: рабочего можно сравнить
    #
    # val - значение, nil, Integer и пр.
    def ==(val)
      @number == val
    end

  end
end