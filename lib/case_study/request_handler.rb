# encoding: utf-8

module CaseStudy
  # Public: воркер процесс - обработчик запроса
  class RequestHandler

    # Public: конструктор
    #
    # client_socket - объект Socket текущего соединения с клиентом
    def initialize(client_socket, request, response)
      @socket = client_socket
      @request = request
      @response = response
    end

    # Public: обработка входящего запроса
    def handle
      @request.parse @socket

      @response.body = @request.path
    end

  end
end