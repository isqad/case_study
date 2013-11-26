# encoding: utf-8

module CaseStudy
  # Public: обертка для клиентского соединения
  #
  # Пример использования:
  # client = socket.accept
  # io = Connection.new(client)
  # TODO: реализовать тех. задание
  class Connection
    # Public: TCPSocket - объект соединения с клиентом
    attr_reader :client

    # Public: конструтор
    #
    # client - объект соединения с клиентом
    def initialize(client)
      @client = client

      @request = ''

      @headers = {
          'Server' => 'CaseStudy Server',
          'Date' => Time.now.utc,
          'Connection' => 'Keep-Alive',
          'Content-Type' => 'text/html; charset=utf-8'
      }

      @response = "HTTP/1.1 200 OK \x0D\x0A"
    end

    # Public: при получении данных из сокета, накапливаем их в @request
    # как только есть окончание строки, отвечаем клиенту
    #
    # data - данные из сокета клиентского соединения
    def on_readable(data)
      @request << data

      if @request.end_with?("\x0D\x0A")

        respond "<p>Отвечает процесс ##{Process.pid}!\nПривет, мир!!!</p>"
        @request = ''
      end
    end

    # Public: обработка записи в клиент
    def on_writable
      bytes = client.write_nonblock @response
      @response = @response.byteslice(bytes..-1)
    end

    # Public: возвращает true, если готов для записи
    def writing?
      !(@response.empty?)
    end

    private
    def respond(message)
      @headers['Content-Length'] = message.bytesize
      @headers.each{ |key, value| @response << "#{key}: #{value} \x0D\x0A" }
      @response << "\x0D\x0A"
      @response << message + "\x0D\x0A"

      on_writable
    end
  end
end
