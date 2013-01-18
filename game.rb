#!/usr/bin/env ruby

require 'gserver'
require 'logger'
require './lib/game'
require './lib/telnet_functions.rb'

Game.new()

class Server < GServer
  def initialize(*args)
    super(*args)

    @@client_id = 0
    @@chat = []
  end

  def serve(io)
    log = Logger.new(STDOUT)
    log.level = Logger::FATAL

    #@@client_id += 1
    #my_client_id = @@client_id

    begin
      attrs = Game::Database::Player.select("*").where("name = '#{Game::Authorize.new(io).get_user}'").first
      Game::Authorize.new(io,attrs).get_pass

      player = Game::Player.new(attrs.name)
      player.io = io
      player.input = TelnetFunctions.handle_telnet(player.io.gets.chomp, player.io)

      loop do
        player.io.print "Health: #{player.attrs.health}> " 
        input = TelnetFunctions.handle_telnet(player.io.gets.chomp, player.io)
        Game::Player::Action.new(player,input)
      end
    rescue StandardError => err
      log.fatal("Caught Exception: #{err.message}")
      log.fatal(err.backtrace)
    end
  end
end

server = Server.new(7777,"0.0.0.0")
server.audit = 1
server.debug = 1
server.start
server.join

puts "Server has been terminated"
