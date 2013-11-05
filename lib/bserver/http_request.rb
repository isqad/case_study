# encoding: utf-8

require 'uri'

module Bserver
  # Public: класс для обработки и извлечения информации из http запроса
  class HttpRequest

    # Public: массив возможных методы
    ALLOW_METHODS = ['GET'].freeze

    # Public: то же самое, что \n. протокол HTTP определяет \x0D\x0A как перевод строки
    LF = "\x0A"

    # Public: то же что и \r
    CR = "\x0D"

    # Public: максимальная длина uri
    MAX_URI_LENGTH = 2073

    # Public: метод запроса (по-умолчанию принимается GET)
    attr_reader :method

    # Public: uri
    attr_reader :uri

    # Public: путь к ресурсу
    attr_reader :path

    # Public: конструктор
    #
    # socket - сокет из которого извлекаем информацию о методе, uri, заголовков запроса
    def initialize(socket)
      request_line = socket.gets(LF, MAX_URI_LENGTH)

      if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d\.\d)?)?\r?\n?/ =~ request_line
        @method = $1
        @uri = $2

        @path = URI(@uri).path
      else
        raise HttpException, 400
      end
    end

  end
end