# encoding: utf-8

require 'socket'

module Bserver
  # Public: методы для создания сокета соединения
  # соединение может быть как через файл сокета (unix сокет),
  # так и через ip и порт (поддерживается IPv4 и IPv6)
  module ServerSocket

    # Public: регулярное выражение для ip v4
    IPV4_REGEX = /\A(((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)):(\d|[1-9]\d|[1-9]\d{2,3}|[1-5]\d{4}|6[0-4]\d{3}|654\d{2}|655[0-2]\d|6553[0-5])\z/

    # Public: IP v6
    IPV6_REGEX = /\A\[([a-fA-F0-9:]+)\]:(\d|[1-9]\d|[1-9]\d{2,3}|[1-5]\d{4}|6[0-4]\d{3}|654\d{2}|655[0-2]\d|6553[0-5])\z/

    # Public: инициализация сокета
    #
    # adress - путь к файлу или ip:port
    def create_socket(address='0.0.0.0:80')
      socket = if File.exists?(address) && File.socket?(address)
        begin
          UNIXSocket.new(address)
        rescue Errno::ECONNREFUSED
          File.unlink(address)
          UNIXServer.new(address)
        end
      elsif IPV4_REGEX =~ address
        tcp_server($1, $5)
      elsif IPV6_REGEX =~ address
        tcp_server($1, $2, :ipv6 => true)
      else
        File.unlink(address) if File.exists?(address)
        UNIXServer.new(address)
      end
      socket
    end

    def tcp_server(ip, port, options={})
      server = Socket.new((options[:ipv6] ? Socket::AF_INET6 : Socket::AF_INET), Socket::SOCK_STREAM, 0)

      addr = Socket.pack_sockaddr_in(port, ip)

      # Опция предотвращает Errno::EADDRINUSE
      # говорит ОС, что сокет можно перебиндить во время TIME_WAIT
      server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      server.bind(addr)
      server.listen(5)
      server
    end
  end
end