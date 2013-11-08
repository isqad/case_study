# encoding: utf-8
# Public: MonkeyPatch - ускоряем отправку статики за счет внедрения sendfile(2) system call
class WEBrick::HTTPResponse
  # Public: данный метод выделен из webrick-high-performance и реализует функционал
  # отправки файла через sendfile(2)
  #
  # socket - соединение с клиентом
  def send_body_io(socket)
    # это вредно. http://www.unixguide.net/network/socketfaq/2.16.shtml
    #socket.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1 # HACK yuck

    if @request_method == "HEAD"
      # ничего не делаем
    elsif @body.kind_of? File
      # используем sendfile(2)
      socket.sendfile @body
    elsif chunked?
      # буферизированный вывод
      while buf = @body.read(BUFSIZE)
        next if buf.empty?
        data = ""
        data << format("%x", buf.size) << CRLF
        data << buf << CRLF
        _write_data(socket, data)
        @sent_size += buf.size
      end
      _write_data(socket, "0#{CRLF}#{CRLF}")
    else
      # тут оригинал
      size = @header['content-length'].to_i
      _send_file(socket, @body, 0, size)
      @sent_size = size
    end
  ensure
    @body.close
  end
end