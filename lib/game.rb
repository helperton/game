require 'active_record'
require 'yaml'
require 'logger'
require_relative 'models.rb'

class Game
  def initialize()
    dbconfig = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(dbconfig)
    #ActiveRecord::Base.logger = Logger.new(STDERR)
    
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
    attr_reader :name, :pass

    def initialize(io)
      @io = io
      @name = nil
      @pass = nil
    end

    def login
      @io.puts "Type 'new' for new player"
      @io.print "Username: "
      @name = TelnetFunc.input(@io.gets.chomp.downcase, @io)
      
      if(@name == "new")
        new!
      else
        @io.print "Password: "
        @pass = TelnetFunc.input(@io.gets.chomp, @io)
        check_creds
      end
    end

    def new!
      l = true
      begin
        @io.print "Desired name: "
        @name = TelnetFunc.input(@io.gets.chomp.downcase, @io)
        if(@name.length < 3)
          @io.puts "Name must be 3 characters or greater."
          next
        end
        if(%r/[^a-zA-Z]/ =~ @name)
          @io.puts "Name must not contain non-alpha characters."
          next
        end
        if(Game::Player.new(name).attrs.nil?)
          l = false
        else
          @io.puts "Name: #{name.capitalize} is unavailable."
        end
      end while(l)
      @io.puts "Name #{name.capitalize} available."
      @io.print "#{name.capitalize}'s password: "
      #TelnetFunc.echo_off(io)
      @pass = TelnetFunc.input(@io.gets.chomp, @io)
      Database::Player.new(:name => @name, :password => @pass, :room => 0, :health => 0).save
      @io.puts "Player created!" 
      @name
    end

    def check_creds
      if(Game::Player.new(name).attrs.password == @pass)
        @io.puts "Welcome!"
        @name
      else
        @io.puts "Wrongo!"
        @io.close()
      end
    end

  end

end


