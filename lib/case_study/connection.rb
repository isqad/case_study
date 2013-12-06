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
    # TODO: реализовать таймаут
    def on_readable(data)
      @request << data

      if @request.end_with?("\x0D\x0A")

        begin
          if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d\.\d)?)?\r?\n?/ =~ @request
            @response.body = Resource.create(URI($2).path)
          else
            raise HttpStatus::BadRequest, "Bad request: #{@request}"
          end
          @request = ''

        rescue HttpStatus::HttpStatusException => e
          @response.body = ErrorResource.new(e)
        rescue Errno::EPIPE => e
          $stderr.puts e.message
          @response.body = ErrorResource.new
        ensure
          respond
          client.close
        end
      end
    end

    private
    def respond
      @response.send_to client
    end
  end
end
