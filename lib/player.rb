class Player
  def initialize(username)
    @player = Models::Player.find_by_username(@username)
    @player.inspect
  end
end


class Action
  @verb = input.split[0]
  @subject = input.split(" ", 2)[1]

  verbs = {
           "quit" => 'quit',
           "exit" => 'quit',
           "look" => 'look',
           "l" => 'look',
           "stat" => 'stat',
           "st" => 'stat',
           "attack" => 'attack',
           "a" => 'attack',
           "/w" => 'whisper_player',
           "/p" => 'whisper_party'
          }
  if(verbs.key?(@verb))
    send(verbs[@verb],@subject)
  elsif(@verb.nil?)
    return
  else
    @player.io.puts "Say what?"
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

