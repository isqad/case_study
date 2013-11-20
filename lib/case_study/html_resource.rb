# encoding: utf-8

module CaseStudy
  class HtmlResource < Resource

    # Public: тип ресурса
    def type
      'text/html'
    end

    def content
      html = <<-_html_
<!doctype html>
<html>
  <head>
    <title>#{@relative_path}</title>
  </head>
<body>
  <h3>#{@relative_path}</h3>
  <ul>
    <li>
      _html_

      files = Dir.entries(@absolute_path).select do |entry|
        entry != '.' && entry != '..'
      end

      files.map! do |f|
        path = @relative_path == '/' ? f : "#{@relative_path}/#{f}"

        icon = File.directory?(@absolute_path + '/' + f) ? '<img src="/folder.png">' : ''

        "<a href=\"#{path}\">#{icon} #{f}</a>"
      end

      html << files.join('</li><li>')

      html << <<-_html_
    </li>
  </ul>
  </body>
</html>
      _html_
    end

    def size
      content.bytesize
    end

    def close
    end
  end
end
