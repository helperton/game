require 'active_record'
require 'yaml'
require 'logger'

class Game
  def initialize()
    dbconfig = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(dbconfig)
    #ActiveRecord::Base.logger = Logger.new(STDERR)
    
    players2location = {}
  end
  
  class Database 
    class Player < ActiveRecord::Base
    end

    class Room < ActiveRecord::Base
    end
  end

  class Room
    def initialize()
    end

    def id2coords(id)
        coords = Database::Room.select("x,y,z").where("id = #{id}").find(1)
    end

    def coords2id(x,y,z)
        coords = Database::Room.select("id").where("x = '#{x}' and y = '#{y} and z = '#{z}'").find(1)
    end
  end


  class Player
    attr_accessor :attrs, :io

    def initialize(p_id=1)
      @attrs = Database::Player.select("*").where("id = #{p_id}").first
    end

    def io
      @io
    end

    class Action
      def initialize(player, input)
        @player = player
        @verb = input.split[0]
        @subject = input.split(" ", 2)[1]
        # Should move verbs to DB
        verbs = { 
                  "quit" => 'quit', 
                  "exit" => 'quit', 
                  "look" => 'look', 
                  "l" => 'look',
                  "stat" => 'stat',
                  "st" => 'stat', 
                  "attack" => 'attack',
                  "a" => 'attack',
                  "/s" => 'say',
                  "/say" => 'say'
                }

        if verbs.key?(@verb)
          send(verbs[@verb],@subject)
        elsif(@input == '')
          nil
        else
          puts "Say what?"
        end
      end
      
      def quit(void)
        puts 'Exiting...'
        exit 0
      end

      def look(arg)
        @player.io.puts Database::Room.select("description").where(@player.attrs.room).first.description
        # Have to detect presence of other objects here
        @player.io.puts "Trying to look at: #{arg}"
      end
      
      def stat(void)
        puts Database::Player.select("*").where(@player.attrs.id).first.inspect
      end
      
      def attack(thing)
        puts "Not working yet! Won't attack #{thing}"
      end
      
      def say(stuff)
        puts "#{@player.attrs.name} says: #{stuff}"
      end
    end
  end

  class World
    def initialize()
      rooms = Database::Room.first
      #puts rooms.inspect
    end
  end
end


