# encoding: utf-8

module CaseStudy
  class Resource

    PUBLIC_DIR = "#{File.dirname(__FILE__)}/../../public"

    def self.create path
      absolute_path = PUBLIC_DIR + path

      raise HttpStatus::NotFound, "Resource #{path} not found" unless File.exists? absolute_path

      if File.directory? absolute_path
        HtmlResource.new(path)
      else
        FileResource.new(path)
      end
    end

    def initialize path
      @absolute_path = PUBLIC_DIR + path
      @path = path
      @template = 'index.html.erb'
    end

    def type
      'text/html'
    end

    def close
    end

  end
end
