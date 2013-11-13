# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('./lib/case_study')

require 'server'

CaseStudy::Server.new.run