# encoding: utf-8

require './lib/bserver/server_socket'
require './lib/bserver/request_handler'

require './lib/bserver/http_response'
require './lib/bserver/http_request'


module Bserver
  # Public: класс отвечающий за запуск сервера
  # данный сервер использует наипростейшую архитектуру -
  # каждый принятый запрос обрабатывается в отдельном процессе
  class Server
    extend ServerSocket

    # Public: запуск сервера
    #
    # addr - String, путь к файлу unix сокета или ip:port
    def self.run(addr)

      trap_signals

      socket = create_socket(addr)

      loop do

        connection, client_addrinfo = socket.accept

        pid = fork do
          begin
            response = HttpResponse.new
            request = HttpRequest.new(connection)

            # Обработка запроса
            RequestHandler.new(request, response).handle
          rescue HttpException => e
            # Установить ошибку в response
            if HttpResponse::HTTP_CODES.has_key?(e.message.to_i)
              response.set_error(e.message.to_i)
            else
              response.set_error(500)
            end
          rescue
            response.set_error(500)
          ensure
            # при любых обстоятельствах сервер должен ответить
            response.send_response(connection)
          end
        end

        connection.close

        Process.detach(pid)
      end
    end


    def self.trap_signals
      [:INT, :QUIT].each do |signal|
        trap(signal) do
          exit
        end
      end
    end

  end
end

