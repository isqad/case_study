# encoding: utf-8

module Bserver
  # Public: предоставляет логирование
  module Logger

    def log(message)
      $stdout.puts "[#{Process.pid}] [#{self.class.name}] #{message}"
    end

    def err(message)
      $stderr.puts "[#{Process.pid}] [#{self.class.name}] #{message}"
    end

  end
end