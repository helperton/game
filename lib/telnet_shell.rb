# taken from https://github.com/darrenhinderer/telnet-server/blob/master/telnet_shell.rb

require_relative 'player.rb'

class TelnetShell

  def initialize(connection)
    @connection = connection
    @player = Player.new(@connection.instance_variable_get(:@telnet_auth).instance_variable_get(:@username))
  end

  def process_response(data)
    if data.downcase.include?("quit")
      @connection.disconnect
      return
    end

    puts @connection.instance_variable_get(:@telnet_auth)

    output = @player.action(data)
    @connection.send_prompt(output)
    send_prompt
  end

  def start
    send_prompt
  end

  private

  def send_prompt
    @connection.send_prompt("$ ")
  end

end
