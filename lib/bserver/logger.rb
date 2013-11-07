# encoding: utf-8

module Bserver
  # Public: предоставляет логирование
  module Logger

    def log(ex)
      $stdout.puts "[#{Process.pid}] [#{self.class.name}] #{format_exception(ex)}"
    end

    def error(ex)
      $stderr.puts "[#{Process.pid}] [#{self.class.name}] #{format_exception(ex)}"
    end

    alias_method :debug, :log
    alias_method :warn, :log
    alias_method :info, :log

    def format_exception(ex)
      if ex.is_a?(Exception)
        "#{arg.class}: #{arg.message}\n\t" <<
        ex.backtrace.join("\n\t") << "\n"
      elsif ex.respond_to?(:to_str)
        ex.to_str
      else
        ex.inspect
      end
    end

    private :format_exception

  end
end