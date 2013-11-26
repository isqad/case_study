# encoding: utf-8

module CaseStudy
  # Public: обертка для клиентского соединения
  #
  # Пример использования:
  # client = socket.accept
  # io = Connection.new(client)
  class Connection
    # Public: TCPSocket - объект соединения с клиентом
    attr_reader :client

    # Public: конструтор
    #
    # client - объект соединения с клиентом
    def initialize(client)
      @client = client

      @request = ''
      @response = ''
    end

    # Public: при получении данных из сокета, накапливаем их в @request
    # как только есть окончание строки, отвечаем клиенту
    #
    # data - данные из сокета клиентского соединения
    def on_readable(data)
      @request << data

      if @request.end_with?("\x0D\x0A")

        respond "HTTP/1.1 200 OK\x0D\x0A\x0D\x0AОтвечает процесс ##{Process.pid}!\nПривет, мир!!!\x0D\x0A"
        @request = ''
      end
    end

    # Public: обработка записи в клиент
    def on_writable
      bytes = client.write_nonblock @response
      client.close if bytes == @response.bytesize # закрываем, если записали столько, сколько нужно
      @response.slice! 0, bytes
    end

    # Public: возвращает true, если готов для записи
    def writing?
      !(@response.empty?)
    end

    # Public: возвращает true, если соединение закрыто
    def closed?
      client.closed?
    end

    private
    def respond(message)
      @response << message + "\x0D\x0A"
      puts "[#{Process.pid}] Try respond:\r\n" + @response + "\r\n==========================\r\n"
      on_writable
    end
  end
end
