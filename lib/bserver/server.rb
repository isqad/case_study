# encoding: utf-8

require 'webrick'

require './lib/bserver/logger'

require './lib/bserver/server_socket'
require './lib/bserver/request_handler'


module Bserver
  # Public: класс отвечающий за запуск сервера
  # данный сервер использует наипростейшую архитектуру -
  # каждый принятый запрос обрабатывается в отдельном процессе
  class Server
    include ServerSocket
    include Logger

    def initialize

      @response = WEBrick::HTTPResponse.new(
        :Logger => self,
        :HTTPVersion => '1.1',
        :ServerSoftware => 'Bserver'
      )

      @request = WEBrick::HTTPRequest.new(:Logger => self)

      $stdout.reopen("#{File.dirname(__FILE__)}/../../log/bserver_out.log")
      $stderr.reopen("#{File.dirname(__FILE__)}/../../log/bserver_err.log")
    end

    # Public: запуск сервера
    #
    # addr - String, путь к файлу unix сокета или ip:port
    def run(addr)

      trap_signals

      socket = create_socket(addr)

      loop do

        client_socket, client_addrinfo = socket.accept

        pid = fork do
          begin
            # Обработка запроса
            RequestHandler.new(client_socket, @request, @response).handle
          rescue WEBrick::HTTPStatus::EOFError, WEBrick::HTTPStatus::RequestTimeout => e
            # Установить ошибку в response
            @response.set_error(e)
          rescue WEBrick::HTTPStatus::Error => e
            error(e)
            @response.set_error(e)
          rescue => e
            error(e)
            @response.set_error(e)
          ensure
            # при любых обстоятельствах сервер должен ответить
            @response.send_response(client_socket)
          end
        end

        client_socket.close

        Process.detach(pid)
      end
    end

    private
    def trap_signals
      [:INT, :QUIT].each do |signal|
        trap(signal) do
          exit
        end
      end
    end

  end
end

