# encoding: utf-8

module CaseStudy
  class HttpResponse

    attr_accessor :body

    attr_accessor :headers

    def initialize
      @headers = {
          'Server' => 'CaseStudy Server',
          'Date' => Time.now.utc,
          'Connection' => 'close'
      }
    end

    def send_to client
      prepare_headers
      client << head_response
      send_body client
    end

    def prepare_headers
      @headers['Content-Type'] = @body.type
      @headers['Content-Length'] = @body.size
    end

    def head_response
      header = "HTTP/1.1 200 OK \x0D\x0A"
      @headers.each{ |key, value| header << "#{key}: #{value} \x0D\x0A" }
      header << "\x0D\x0A"
    end

    def send_body client
      if @body.content.is_a?(File)
        client.sendfile @body.content
      else
        client << @body.content
      end
    end
  end
end
