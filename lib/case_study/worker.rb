# encoding: utf-8

module CaseStudy
  # Public: воркер процесс
  class Worker

    # Public: конструктор
    #
    # socket - TCPSocket
    def initialize socket
      @main_socket = socket
      $0 = "Bserver worker [#{Process.pid}]"

      @queue = {} # очередь соединений
    end

    # Public: обработка входящего запроса
    # Если клиент присоединился, принимаем соединение
    # Здесь мы используем неблокирующее принятие соединения, для того, чтобы
    # обрабатывать остальные соединения в очереди
    def handle
      loop do
        readable_clients, writable_clients = IO.select(read_ready + [@main_socket])

        handle_read readable_clients
      end
    end

    private
    # Internal: принимаем или читаем соединение
    def handle_read clients
      clients.each do |socket|
        if @main_socket == socket
            client_socket = @main_socket.accept
            @queue[client_socket.fileno] = Connection.new(client_socket)
        else
          read socket
        end
      end
    end

    # Internal: неблокируещее чтение клиента
    #
    # client - TCPSocket, клиентское соединение
    def read client
      connection = @queue[client.fileno]
      data = client.read_nonblock(1024)
      connection.on_readable(data)
      @queue.reject!{ |fileno, conn| conn.client.closed? }
    rescue Errno::EAGAIN
    rescue EOFError
      @queue.delete(client.fileno)
    end

    # Internal: готовые к чтению клиенты
    #
    # return array[TCPSocket]
    def read_ready
      @queue.values.map(&:client)
    end

  end
end
