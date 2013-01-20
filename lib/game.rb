require 'active_record'
require 'yaml'
require 'logger'

class Game
  def initialize()
    dbconfig = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(dbconfig)
    #ActiveRecord::Base.logger = Logger.new(STDERR)
    
  end

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
        #attrs = Game::Database::Player.select("*").where("name = '#{Game::Authorize.new(io).get_user}'").first
        Game::Auth.new(io).login

        player = Game::Player.new(attrs.name)
        player.io = io
        player.input = TelnetFunc.input(player.io.gets.chomp, player.io)

        loop do
          player.io.print "Health: #{player.attrs.health}> "
          input = TelnetFunc.input(player.io.gets.chomp, player.io)
          Game::Player::Action.new(player,input)
        end

      rescue StandardError => err
        log.fatal("Caught Exception: #{err.message}")
        log.fatal(err.backtrace)
      end
    end
  end

  class Database 
    class Player < ActiveRecord::Base
      #attr_accessible :name, :password, :description, :room, :health
    end

    class Room < ActiveRecord::Base
      #attr_accessible :x, :y, :z, :description
    end
  end

  class Room
    def initialize()
    end

    def all
      Database::Room.find(:all)
    end

    def id2coords(id)
      coords = Database::Room.select("x,y,z").where("id = #{id}").find(1)
    end

    def coords2id(x,y,z)
      coords = Database::Room.select("id").where("x = '#{x}' and y = '#{y} and z = '#{z}'").find(1)
    end
  end

  class Player
    attr_accessor :attrs, :io, :input, :output

    def initialize(name)
      @attrs = Database::Player.select("*").where("name = '#{name}'").first
      #@attrs = Database::Player.where(:name => name)
    end

    def io
      @io
    end

    def input
      @input
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

        if(verbs.key?(@verb))
          send(verbs[@verb],@subject)
        elsif(@verb.nil?)
          return
        else
          @player.io.puts "Say what?"
        end
      end

      def quit(void)
        puts 'Exiting...'
        @player.io.close()
      end

      def look(arg)
        @player.io.puts Database::Room.select("description").where(@player.attrs.room).first.description
        # Have to detect presence of other objects here
        @player.io.puts "Trying to look at: #{arg}"
      end
      
      def stat(void)
        @player.io.puts Database::Player.select("*").where(@player.attrs.id).first.inspect
      end
      
      def attack(thing)
        @player.io.puts "Not working yet! Won't attack #{thing}"
      end
      
      def say(stuff)
        @player.io.puts "#{@player.attrs.name} says: #{stuff}"
      end
    end
  end

  class World
    attr_reader :rooms

    def initialize()
      @rooms = Database::Room.all
      #puts rooms.inspect
      players2location = {}
    end
  end

  class Auth
    def initialize(io)
      @io = io
    end

    def login
      @io.puts "Type 'new' for new player"
      @io.print "Username: "
      user = TelnetFunc.input(@io.gets.chomp.downcase, @io)
      
      if(user == "new")
        new!
      else
        @io.print "Password: "
        pass = TelnetFunc.input(@io.gets.chomp, @io)
        check(user,pass)
      end
    end

    def new!
      begin
        @io.print "Desired name: "
        name = TelnetFunc.input(@io.gets.chomp.downcase, @io)
      end while(Game::Player.new(name).attrs != nil and @io.puts "Name #{name} unavailable.")
      @io.print "password: "
      pass = TelnetFunc.input(@io.gets.chomp, @io)
      Database::Player.new(:name => name, :password => pass, :room => 0, :health => 0).save
      @io.puts "Player created!" 
    end

    def check(user,pass)
      if(Game::Database::Player.new(user).password == pass)
        @io.puts "Welcome!"
      else
        @io.puts "Wrongo!"
        @io.close()
      end
    end

  end

end


