# encoding: utf-8

module CaseStudy
  class FileResource < Resource

    def size
      content.size
    end

    def content
      File.open(@absolute_path, 'r')
    end

    def type
      mime_type @absolute_path
    end

    def close
      content.close unless content.closed?
    end

    private
    def mime_type(file)
      case File.extname(file)
        when '.ico'  then 'image/vnd.microsoft.icon'
        when '.zip'  then 'application/zip'
        when '.gz'   then 'application/x-gzip'
        when '.html' then 'text/html'
        when '.txt'  then 'text/plain'
        when '.png'  then 'image/png'
        when '.jpg'  then 'image/jpeg'
        else 'application/octet-stream'
      end
    end
  end
end
