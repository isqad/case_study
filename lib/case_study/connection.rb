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

      @response = HttpResponse.new
    end

    # Public: при получении данных из сокета, накапливаем их в @request
    # как только есть окончание строки, отвечаем клиенту
    #
    # data - данные из сокета клиентского соединения
    def on_readable(data)
      @request << data

      if @request.end_with?("\x0D\x0A")
        if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d\.\d)?)?\r?\n?/ =~ @request
          path = @public_dir + URI($2).path
          @response.body = "<h1>Success #{path}</h1>"
        else
          @response.body = '<h1>Bad request</h1>'
        end
        @request = ''

        respond
      end
    end

    private
    def respond
      @response.send_to client
    ensure
      client.close
    end
  end
end
