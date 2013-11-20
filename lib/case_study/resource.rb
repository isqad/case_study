# encoding: utf-8

module CaseStudy
  # Public: класс представляет собой запрашиваемый ресурс
  class Resource

    PUBLIC_DIR = "#{File.dirname(__FILE__)}/../../public"

    def self.create(path)
      absolute_path = PUBLIC_DIR + path

      raise '404 Not Found' unless File.exists?(absolute_path)

      if File.directory?(absolute_path)
        HtmlResource.new(path)
      else
        FileResource.new(path)
      end
    end

    def initialize(path)
      @relative_path = path
      @absolute_path = PUBLIC_DIR + @relative_path
    end
  end
end
