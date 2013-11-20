# encoding: utf-8

module CaseStudy
  class FileResource < Resource

    # Public: mime-type файла
    def type
      case File.extname(@absolute_path)
        when '.ico'  then 'image/vnd.microsoft.icon'
        when '.zip'  then 'application/zip'
        when '.gz'   then 'application/x-gzip'
        when '.html' then 'text/html'
        when '.png'  then 'image/png'
        else 'application/octet-stream'
      end
    end

    def content
      File.open(@absolute_path, 'r')
    end

    def size
      content.size
    end

    def close
      content.close
    end
  end
end
