# encoding: utf-8

module CaseStudy
  class HtmlResource < Resource

    def size
      content.bytesize
    end

    def content
      ERB.new(File.read("#{File.dirname(__FILE__)}/html/#{@template}")).result(binding)
    end

    def set_error e
      @error = e
      @template = 'error.html.erb'
      content
    end
  end
end
