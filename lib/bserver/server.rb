# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'webrick'
require 'sendfile'

# TODO: тут какие-то сорняки...
require './lib/bserver/logger'
require './lib/bserver/server_socket'
require './lib/bserver/request_handler'

# Public: MonkeyPatch - ускоряем отправку статики за счет внедрения sendfile(2) system call
class WEBrick::HTTPResponse
  # Public: данный метод выделен из webrick-high-performance и реализует функционал
  # отправки файла через sendfile(2)
  #
  # socket - соединение с клиентом
  def send_body_io(socket)
    # это вредно. http://www.unixguide.net/network/socketfaq/2.16.shtml
    #socket.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1 # HACK yuck

    if @request_method == "HEAD"
      # ничего не делаем
    elsif @body.kind_of? File
      # используем sendfile(2)
      socket.sendfile @body
    elsif chunked?
      # буферизированный вывод
      while buf = @body.read(BUFSIZE)
        next if buf.empty?
        data = ""
        data << format("%x", buf.size) << CRLF
        data << buf << CRLF
        _write_data(socket, data)
        @sent_size += buf.size
      end
      _write_data(socket, "0#{CRLF}#{CRLF}")
    else
      # тут оригинал
      size = @header['content-length'].to_i
      _send_file(socket, @body, 0, size)
      @sent_size = size
    end
  ensure
    @body.close
  end
end

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

        # TODO: это все фигня. Переделаем по-правильному
        pid = fork do
          begin
            # Обработка запроса
            RequestHandler.new(client_socket, @request, @response).handle
          rescue WEBrick::HTTPStatus::EOFError, WEBrick::HTTPStatus::RequestTimeout => e
            # Установить ошибку в response
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

