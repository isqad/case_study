# encoding: utf-8

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

require 'socket'
require 'uri'
require 'sendfile'

require 'request'
require 'response'
require 'request_handler'


module CaseStudy
  # Public: класс отвечающий за запуск сервера
  # архитектура префоркинга
  class Server

    # Public: сигналы завершения
    EXIT_SIGNALS = [ :QUIT, :INT, :TERM ]

    # Public: рабочие
    WORKERS = []

    # Public: кол-во рабочих
    NUM_WORKERS = 4

    def initialize(port=8080)
      @socket = TCPServer.new(port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      $stderr.reopen("#{File.dirname(__FILE__)}/../../log/bserver_err.log", "a")
    end

    # Public: запуск сервера
    #
    # port - порт
    def run(port=8080)

      trap_signals

      $0 = 'Bserver master'

      spawn_workers

      Process.waitall

    ensure
      @socket.close
    end

    private
    # Internal: обеспечение необходимого кол-ва рабочих
    def spawn_workers
      worker_num = 0
      while worker_num < NUM_WORKERS

        worker = RequestHandler.new(@socket)

        # обработка в дочернем процессе
        pid = fork do
          $0 = "Bserver worker [#{Process.pid}]"
          worker.handle while true
          exit
        end

        WORKERS << pid

        worker_num += 1
      end
    end


    def trap_signals
      EXIT_SIGNALS.each do |signal|
        trap(signal) do
          exit
        end
      end
    end

  end
end

