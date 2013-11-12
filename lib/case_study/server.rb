# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'socket'
require 'webrick'
require 'sendfile'

require './lib/case_study/patch'
require './lib/case_study/logger'
require './lib/case_study/request_handler'


module CaseStudy
  # Public: класс отвечающий за запуск сервера
  # выбрана архитектура префоркинга
  class Server
    include Logger

    # Public: сигналы завершения
    EXIT_SIGNALS = [ :QUIT, :INT, :TERM ]

    # Public: рабочие
    WORKERS = []

    # Public: кол-во рабочих
    NUM_WORKERS = 4

    def initialize(port=8080)
      @socket = TCPServer.new(port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      $stdout.reopen("#{File.dirname(__FILE__)}/../../log/bserver_out.log", "a")
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
          worker.handle
          exit
        end

        WORKERS << pid

        worker_num += 1
      end
    end


    def trap_signals
      EXIT_SIGNALS.each do |signal|
        trap(signal) do
          WORKERS.each{ |pid| Process.kill(signal, pid) }
          exit
        end
      end
    end

  end
end

