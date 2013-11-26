# encoding: utf-8

module CaseStudy
  # Public: воркер процесс
  class Worker

    # Public: конструктор
    #
    # socket - TCPSocket
    def initialize(socket)
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
    # Internal: готовые к чтению
    def read_ready
      @queue.values.map(&:client)
    end

    # Internal: принимаем и читаем соединение
    def handle_read(clients)
      clients.each do |socket|
        if @main_socket == socket
            client_socket = @main_socket.accept
            @queue[client_socket.fileno] = Connection.new(client_socket)
        else
          begin
            connection = @queue[socket.fileno]
            data = socket.read_nonblock(1024)
            puts "[#{Process.pid}] Received: " + data + "\r\n"
            connection.on_readable(data)
            @queue.reject!{ |fileno, conn| conn.client.closed? }
          rescue Errno::EAGAIN
          rescue EOFError
            @queue.delete(socket.fileno)
          end
        end
      end
    end

  end
end
