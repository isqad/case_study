# encoding: utf-8

module CaseStudy
  # Public: представление http ответа
  class HttpResponse

    # Public: тело ответа
    attr_accessor :body

    # Public: заголовки
    attr_accessor :headers

    def initialize
      @headers = {
          'Server' => 'CaseStudy Server',
          'Date' => Time.now.utc,
          'Connection' => 'close'
      }
    end

    # Public: отправка ответа в клиентское соединение
    #
    # client - TCPSocket, клиентское соединение
    def send_to client
      prepare_headers
      client << header
      send_body client
    end

    # Public: отправка тела в клиентское соединение
    #
    # client - TCPSocket, клиентское соединение
    def send_body client
      if @body.content.is_a?(File)
        client.sendfile @body.content
      else
        client << @body.content
      end
    end

    # Public: заголовок ответа
    #
    # return String
    def header
      header = "HTTP/1.1 200 OK \x0D\x0A"
      @headers.each{ |key, value| header << "#{key}: #{value} \x0D\x0A" }
      header << "\x0D\x0A"
    end

    private
    # Internal: подготовка заголовков
    def prepare_headers
      @headers['Content-Type'] = @body.type
      @headers['Content-Length'] = @body.size
    end

  end
end
