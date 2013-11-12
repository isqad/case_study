# encoding: utf-8

module CaseStudy
  # Public: воркер процесс - обработчик запроса
  class RequestHandler
    include Logger

    # Public: порядковый номер рабочего
    attr_accessor :number

    # Public: конструктор
    #
    # socket - TCPSocket
    # number - порядковый номер
    def initialize(socket, number)

      @socket = socket

      @response = WEBrick::HTTPResponse.new(
        :Logger => self,
        :HTTPVersion => '1.1',
        :ServerSoftware => 'Bserver'
      )

      @request = WEBrick::HTTPRequest.new(:Logger => self)

      @number = number

      @public_dir = "#{File.dirname(__FILE__)}/../../public"
    end

    # Public: обработка входящего запроса
    def handle

      $0 = "Bserver worker ##{@number}"

      while true

        client = @socket.accept

        client.sync = true

        begin

          @request.parse client

          file = "#{@public_dir}#{@request.path}"

          raise WEBrick::HTTPStatus::NotFound unless File.exists?(file)

          @response.body = if File.directory?(file)
            get_content_dir(file, @request.path)
          else
            File.open(file, "r")
          end

        rescue WEBrick::HTTPStatus::Status, WEBrick::HTTPStatus::EOFError, WEBrick::HTTPStatus::RequestTimeout => e
          # Установить ошибку в response
          @response.set_error(e)
        rescue => e
          error(e)
          @response.set_error(e)
        ensure
          # при любых обстоятельствах сервер должен ответить
          @response.send_response(client)
          client.close
        end
      end
    end

    # Public: рабочего можно сравнить
    #
    # val - значение, nil, Integer и пр.
    def ==(val)
      @number == val
    end

    private
    # Internal: список файлов в директории
    # возвращает html
    #
    # directory - String, абсолютный путь
    def get_content_dir(directory, relative)
      output = <<-_html_
<!doctype html>
<html>
  <head>
    <title>#{relative}</title>
  </head>
<body>
  <h3>#{relative}</h3>
  <ul>
    <li>
_html_
      files = Dir.entries(directory).select{ |entry| entry != '.' && entry != '..' }

      files.map! do |f|
        path = relative == '/' ? f : "#{relative}/#{f}"
        icon = File.directory?(directory + '/' + f) ? '<img src="/folder.png">' : ''

        "<a href=\"#{path}\">#{icon} #{f}</a>"
      end

      output += files.join('</li><li>')

      output += <<-_html_
    </li>
  </ul>
  </body>
</html>
_html_
      output
    end

  end
end