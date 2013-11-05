# encoding: utf-8

module Bserver
  class HttpException < ::StandardError; end
  # Public: Класс предназначенный для создания объектов HTTP ответа
  class HttpResponse

    # Public: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    HTTP_CODES = {
      200 => 'Ok',
      201 => 'Created',
      204 => 'No Content',
      301 => 'Moved Permanently',
      302 => 'Found',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Long',
      500 => 'Internal Server Error'
    }

    # Public: то же самое, что \n. протокол HTTP определяет \x0D\x0A как перевод строки
    LF = "\x0A"

    # Public: то же что и \r
    CR = "\x0D"

    CRLF = "\x0D\x0A"

    # Public: Integer, код ответа
    attr_accessor :code

    # Public: объект IO или String
    attr_accessor :body

    def initialize
      # Код ответа
      @code = 200
      # Заголовок ответа
      @header = {}
      # Тело
      @body = ''
    end

    # Public: формирование и отправка ответа http клиенту
    #
    # socket - объект Socket клиентского соединения
    def send_response(socket)

      # заголовки по-умолчанию
      if @code == 304 || @code == 204
        @header.delete('Content-Length')
        @body = ''
      elsif @header['Content-Length'].nil?
        unless @body.kind_of?(IO)
          @header['Content-Length'] = @body ? @body.bytesize : 0
        end
      end

      if @header['Connection'].nil?
        @header['Connection'] = 'close'
      end

      send_header(socket)
      send_body(socket)
    end

    # Public: строка статуса ответа
    def status_line
      "HTTP/1.1 #{@code} #{reason} #{CRLF}"
    end

    def reason
      HTTP_CODES[@code]
    end

    # Public: установка страницы для вывода ошибок
    #
    # code - HTTP код ошибки
    def set_error(code)
      @code = code
      @header['Content-Type'] = 'text/html; charset=utf-8'

      @body << <<-_page_error
<!doctype html>
<html>
<head>
<title>#{code} #{reason}</title>
</head>
<body>
<h1>#{code} #{reason}</h1>
</body>
</html>
      _page_error
    end

    # Public: заголовок ответа
    def [](key)
      @header[key]
    end

    # Public: установить заголовок
    def []=(key, value)
      @header[key] = value
    end

    def to_s
      socket = ''
      send_response(socket)
      socket
    end

    private
    def send_header(socket)
      data = status_line
      @header.each do |key, value|
        data << "#{key}: #{value}" << CRLF
      end
      data << CRLF
      socket << data
    end

    def send_body(socket)
      data = @body
      socket << data
    end

  end
end