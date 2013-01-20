#!/usr/bin/env ruby

require 'gserver'
require './lib/game'
require './lib/telnet_func.rb'

Game.new()

puts Game::World.new().rooms.inspect

server = Game::Server.new(7777,"0.0.0.0")
server.audit = 1
server.debug = 1
server.start
server.join

puts "Server has been terminated"
