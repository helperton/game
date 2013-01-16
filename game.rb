#!/usr/bin/env ruby
   
require './lib/game'
    
Game.new()

db_player = Game::Database::Player.where("id = 1")
db_room = Game::Database::Room.where("id = 1")
#puts db_player.inspect
#puts db_room.inspect

$player = Game::Player.new()


def prompt
  print "Health: #{$player.attrs.health}> "
  input = STDIN.gets
  Game::Player::Action.new($player,input.chomp)
end

while(1)
  prompt
end

