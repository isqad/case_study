# encoding: utf-8

require 'rubygems'
require 'bundler/setup'

require 'webrick'
require 'sendfile'

require './lib/bserver/patch'
require './lib/bserver/logger'
require './lib/bserver/server_socket'
require './lib/bserver/request_handler'


module CaseStudy
  # Public: класс отвечающий за запуск сервера
  # выбрана архитектура префоркинга
  class Server
    include ServerSocket
    include Logger

    # Public: сигналы завершения
    EXIT_SIGNALS = [ :QUIT, :INT, :TERM ]

    # Public: рабочие
    WORKERS = {}

    # Public: кол-во рабочих
    NUM_WORKERS = 4

    def initialize
      $stdout.reopen("#{File.dirname(__FILE__)}/../../log/bserver_out.log")
      $stderr.reopen("#{File.dirname(__FILE__)}/../../log/bserver_err.log")
    end

    # Public: запуск сервера
    #
    # addr - String, путь к файлу unix сокета или ip:port
    def run(addr)

      trap_signals

      $0 = 'Bserver master'

      @socket = create_socket(addr)

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
        # если уже есть то пропускаем
        next if WORKERS.value?(worker_num)

        worker = RequestHandler.new(@socket, worker_num)

        # обработка в дочернем процессе
        pid = fork do
          worker.handle
          exit
        end

        WORKERS[pid] = worker

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

