#!/usr/bin/env ruby

require 'logger'
require_relative 'lib/telnet_server'
require_relative 'lib/game'


begin
  Game.new()
  EM::run {
    EM::start_server("0.0.0.0", 7777, TelnetServer)
    puts "Telnet Server Started"
  }
rescue StandardError => err
  log = Logger.new(STDOUT)
  log.level = Logger::FATAL
  log.fatal("Caught Exception: #{err.message}")
  log.fatal(err.backtrace)
end
