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
        @queue.select!{ |fileno, conn| !conn.closed? }

        readable_clients, writable_clients = IO.select(read_ready + [@main_socket], write_ready)

        handle_read readable_clients
        handle_write writable_clients
      end
    end

    private
    # Internal: готовые к чтению
    def read_ready
      @queue.values.map(&:client)
    end

    # Internal: готовые к записи
    def write_ready
      @queue.values.select(&:writing?).map(&:client)
    end

    # Internal: принимаем и читаем соединение
    def handle_read(clients)
      clients.each do |socket|
        begin
          if @main_socket == socket
              client_socket = @main_socket.accept_nonblock
              @queue[client_socket.fileno] = Connection.new(client_socket)
          else
            connection = @queue[socket.fileno]
            data = socket.read_nonblock(4096)
            connection.on_readable(data)
            puts "[#{Process.pid}] Read data from socket:\r\n" + data + "\r\n==========================\r\n"
          end
        rescue Errno::EAGAIN
        rescue EOFError
          @queue.delete(socket.fileno)
        end
      end
    end

    # Internal: отдаем остатки данных в сокет
    def handle_write(clients)
      clients.each{ |socket| @queue[socket.fileno].on_writable }
    end

  end
end
