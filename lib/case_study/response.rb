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

    # Public: коды ошибок
    CODE_ERRORS = [
      '404 Not Found',
      '400 Bad Request'
    ]

    def initialize

      @status_code = '200 OK'

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
      prepare_headers
      send_headers client
      send_body client
    ensure
      client.close
    end

    # Public: установка ответа об ошибке
    #
    # status_error - код ответа
    # exception - исключение
    def set_error(e)
      backtrace = e.backtrace.join("\n\t")
      message = e.message
      time = Time.now.utc

      @status_code = if CODE_ERRORS.include?(message)
        message
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
    #{message}
    <HR>
    <PRE>
    #{backtrace}#{"\n"}
    </PRE>
  </BODY>
</HTML>
      _html_

      $stderr.puts "[#{time}] [#{Process.pid}]: #{message}\n#{backtrace}\n"
    end

    private
    # Internal: подготовка необходимых заголовков
    # в зависимости от тела ответа
    def prepare_headers
      # Content-Length
      @headers['Content-Length'] = @body.size unless @headers.has_key? 'Content-Length'
      # Content-Type
      @headers['Content-Type'] = @body.type
    end

    # Internal: подготавливает тело ответа
    #def prepare_body
    #  if File.directory? @resource
    #    set_dir_list(@resource)
    #  else
    #    @body = File.open(@resource, 'r')
    #  end
    #end

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
      if @body.content.kind_of?(File)
        client.sendfile @body.content
      else
        client << @body.content
      end
    ensure
      @body.close
    end

  end
end
