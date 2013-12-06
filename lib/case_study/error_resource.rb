# encoding: utf-8

module CaseStudy
  class ErrorResource < HtmlResource

    def initialize e=nil
      @error = e.nil? ? HttpStatus::InternalServerError.new : e
      @template = 'error.html.erb'
    end

  end
end
