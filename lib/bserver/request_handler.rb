# encoding: utf-8

module Bserver
  # Public: воркер процесс - обработчик запроса
  class RequestHandler

    # Public: конструктор
    #
    # client_socket - объект Socket текущего соединения с клиентом
    def initialize(request, response)
      @request = request
      @response = response
    end

    # Public: обработка входящего запроса
    def handle

    end

  end
end