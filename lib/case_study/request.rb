# encoding: utf-8

module CaseStudy
  # Public: парсит запрос и получает путь к требуемому ресурсу
  class Request
    # Public: путь до ресурса
    attr_reader :path

    def parse(socket)
      request_line = socket.gets("\x0A")

      if /^(\S+)\s+(\S+)(?:\s+HTTP\/(\d\.\d)?)?\r?\n?/ =~ request_line
        @path = URI($2).path
      else
        raise '400 Bad Request'
      end
    end

  end
end