# encoding: utf-8

module CaseStudy
  # Public: ответ сервера
  class Response

    # Public: тело ответа
    attr_accessor :body

    # Public: заголовки ответа
    attr_accessor :headers

    # Public: код ответа
    attr_accessor :status_code

    # Public: запрашиваемый ресурс
    attr_writer :resource

    # Public: рабочая директория
    attr_accessor :public_dir

    # Public: коды ошибок
    CODE_ERRORS = [
      '404 Not Found',
      '400 Bad Request'
    ]

    def initialize
      @public_dir = "#{File.dirname(__FILE__)}/../../public"

      @status_code = '200 OK'

      @resource = "#{@public_dir}/"

      @body = ''

      @headers = {
        'Server' => 'CaseStudy Server',
        'Date' => Time.now.utc,
        'Connection' => 'close',
        'Content-Type' => 'text/html; charset=utf-8'
      }
    end

    # Public: отправка ответа клиенту
    #
    # client - socket клиентского соединения
    def send_response(client)
      prepare_body

      prepare_headers

      send_headers client
      send_body client
    end

    # Public: установка ответа об ошибке
    #
    # status_error - код ответа
    # exception - исключение
    def set_error(exception)

      @status_code = if CODE_ERRORS.include?(exception.message)
        exception.message
      else
        '500 Internal Sever Error'
      end

      @body = <<-_html_
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
  <HEAD>
    <TITLE>#{@status_code}</TITLE>
  </HEAD>
  <BODY>
    <H1>#{@status_code}</H1>
    #{exception.message}
    <HR>
    <PRE>
    #{exception.backtrace.join("\n\t")}#{"\n"}
    </PRE>
  </BODY>
</HTML>
      _html_
    end

    private
    # Internal: подготовка необходимых заголовков
    # в зависимости от тела ответа
    def prepare_headers
      # Content-Length
      unless @headers.has_key? 'Content-Length'
        @headers['Content-Length'] = if @body.kind_of?(File)
          @body.size
        else
          @body ? @body.to_s.bytesize : 0
        end
      end
      # Content-Type
      @headers['Content-Type'] = mime_type(@body) if @body.kind_of?(File)
    end

    # Internal: подготавливает тело ответа
    def prepare_body
      if File.directory? @resource
        set_dir_list(@resource)
      else
        @body = File.open(@resource, 'r')
      end
    end

    # Internal: отправка заголовков
    #
    # client - socket клиентского соединения
    def send_headers(client)
      response = "HTTP/1.1 #{@status_code} \x0D\x0A"
      @headers.each{ |key, value| response << "#{key}: #{value} \x0D\x0A" }
      response << "\x0D\x0A"

      client << response
    end

    # Internal: отправка тела ответа в сокет
    #
    # client - socket клиентского соединения
    def send_body(client)
      if @body.kind_of?(File)
        client.sendfile @body
      else
        client << @body
      end
    ensure
      @body.close if @body.kind_of?(File)
    end

    # Internal: установка ответа списка файлов
    #
    # directory - String, абсолютный путь
    def set_dir_list(directory)
      relative = directory.gsub(@public_dir, '')

      @body = <<-_html_
<!doctype html>
<html>
  <head>
    <title>#{relative}</title>
  </head>
<body>
  <h3>#{relative}</h3>
  <ul>
    <li>
      _html_

      files = Dir.entries(directory).select{ |entry| entry != '.' && entry != '..' }

      files.map! do |f|
        path = relative == '/' ? f : "#{relative}/#{f}"
        icon = File.directory?(directory + '/' + f) ? '<img src="/folder.png">' : ''

        "<a href=\"#{path}\">#{icon} #{f}</a>"
      end

      @body << files.join('</li><li>')

      @body << <<-_html_
    </li>
  </ul>
  </body>
</html>
      _html_
    end

    # Internal: определяет mime-type файлов по их расширению
    #
    # file - файл
    def mime_type(file)
      case File.extname(file)
      when '.ico'  then 'image/vnd.microsoft.icon'
      when '.zip'  then 'application/zip'
      when '.gz'   then 'application/x-gzip'
      when '.html' then 'text/html'
      when '.png'  then 'image/png'
      else 'application/octet-stream'
      end

    end

  end
end